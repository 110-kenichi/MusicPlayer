// See https://aka.ms/new-console-template for more information
//using HeatshrinkDotNet;
using HeatshrinkDotNet;
using System.IO.Compression;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;

const int SPLIT_SIZE = 16384 - 512;

void writeWait(List<byte> outputData, int wait)
{
    if (wait != 0)
    {
        wait--;
        if (wait <= 255)
        {
            if (wait < 8)
                outputData.Add((byte)(0x80 + wait));
            else
            {
                outputData.Add((byte)0x8d);
                outputData.Add((byte)wait);
            }
        }
        else
        {
            for (int i = 0; i < wait / 255; i++)
            {
                outputData.Add((byte)0x8d);
                outputData.Add((byte)255);
            }
            if ((wait & 255) != 0)
            {
                outputData.Add((byte)0x8d);
                outputData.Add((byte)(wait & 255));
            }
        }
    }
}

void writeWaitAndData(List<byte> outputData, byte data, int waitN)
{
    if (waitN == 0)
        outputData.Add(data);
    else if (waitN == 1)
        outputData.Add((byte)(data | 0x40));
    else
    {
        writeWait(outputData, waitN);
        outputData.Add(data);
    }
}

//Read
for (int i = 0; i < args.Length; i++)
{
    string vgmfile = args[i];
    List<byte> convVgmData = new List<byte>();

    var rawVgmData = File.ReadAllBytes(vgmfile);
    if (rawVgmData[0] == 'V' && rawVgmData[1] == 'g' && rawVgmData[2] == 'm')
    {

    }
    else if (rawVgmData[0] == 0x1f && rawVgmData[1] == 0x8b && rawVgmData[2] == 0x08)
    {
        byte[] buffer = new byte[4096];
        int size = 0;

        GZipStream gzStream = new GZipStream(new MemoryStream(rawVgmData), CompressionMode.Decompress);
        while ((size = gzStream.Read(buffer, 0, buffer.Length)) > 0)
            convVgmData.AddRange(buffer.Take(size));
        rawVgmData = convVgmData.ToArray();
        convVgmData.Clear();
    }
    else
    {
        Console.WriteLine("Unknown format file: " + vgmfile);
        continue;
    }

    var loop_ofst = convertVgmFile(convVgmData, rawVgmData);
    //File.WriteAllBytes(vgmfile + ".dat", convVgmData.ToArray());

    //Compress
    byte[] comp = convVgmData.ToArray();
    bool compressed = false;
#if COMPRESS
    if (comp.Length > 16384-512)
    {
        compressed = true;
        compressVgmFile(convVgmData, out comp);
    }
#endif
    //Output
    int idx = 0;
    foreach (var sarray in Split(comp, SPLIT_SIZE))
    {
        writeCompressedVgmFile(vgmfile, idx, sarray.ToArray(), compressed, loop_ofst);
        idx++;
    }
}

static IEnumerable<IEnumerable<T>> Split<T>(T[] arr, int size)
{
    return arr.Select((s, i) => arr.Skip(i * size).Take(size)).Where(a => a.Any());
}

static void writeCompressedVgmFile(string vgmfile, int idx, byte[] comp, bool compressed, int loop_ofst)
{
    StringBuilder sb = new StringBuilder();
    string mname = Path.GetFileNameWithoutExtension(vgmfile) + "_" + idx.ToString();
    mname = Regex.Replace(mname, @"[\s()[\]\-+]", "_", RegexOptions.Compiled);

    if (idx == 0)
    {
        if (idx * SPLIT_SIZE <= loop_ofst && loop_ofst < (idx + 1) * SPLIT_SIZE)
        {
            sb.AppendLine("//extern const unsigned char " + mname + "_LoopBankNo;");
            sb.AppendLine("//extern const unsigned short " + mname + "_LoopBanOffset;");
        }
    }
    sb.AppendLine("//extern const unsigned char " + mname + "_Compressed;");
    sb.AppendLine("extern const unsigned short " + mname + "_Size;");
    sb.AppendLine("extern const unsigned char " + mname + "_Data[];");

    sb.AppendLine();

    if (idx == 0)
    {
        if (idx * SPLIT_SIZE <= loop_ofst && loop_ofst < (idx + 1) * SPLIT_SIZE)
        {
            sb.AppendLine("//const unsigned char " + mname + "_LoopBankNo =" + idx + ";");
            sb.AppendLine("//const unsigned short " + mname + "_LoopBankOffset =" + (loop_ofst % SPLIT_SIZE) + ";");
        }
    }
    sb.AppendLine("//const unsigned char " + mname + "_Compressed = " + (compressed ? 1 : 0) + ";");
    sb.AppendLine("const unsigned short " + mname + "_Size = " + comp.Length.ToString() + ";");
    sb.AppendLine("const unsigned char " + mname + "_Data[] = {");
    for (var i = 0; i < comp.Length; i += 16)
    {
        sb.Append("\t");
        for (var j = 0; i + j < Math.Min(i + 16, comp.Length); j++)
            sb.Append("0x" + comp[i + j].ToString("X2") + ", ");
        sb.AppendLine();
    }
    sb.AppendLine("};");
    File.WriteAllText(Path.Combine(Path.GetDirectoryName(vgmfile),mname + ".h"), sb.ToString());
}

static void compressVgmFile(List<byte> cnvVgmData, out byte[] comp)
{
    var encoder = new HeatshrinkEncoder(11, 4);
    var inputData = cnvVgmData.ToArray();
    var inputSize = cnvVgmData.Count;
    List<byte> vs = new List<byte>();
    var sunkedCount = 0;
    while (true)
    {
        var count = 0;
        do
        {
            var esres = encoder.Sink(inputData, sunkedCount, inputSize - sunkedCount, out count);
            sunkedCount += count;
            EncoderPollResult pres;
            do
            {
                var polledData = new byte[4096];
                pres = encoder.Poll(polledData, 0, polledData.Length, out count);
                vs.AddRange(polledData.Take(count));
            } while (pres == EncoderPollResult.More);
        } while (sunkedCount < inputSize);
        var res = encoder.Finish();
        if (res == EncoderFinishResult.Done)
            break;
    }
    comp = vs.ToArray();
}

int convertVgmFile(List<byte> cnvVgmData, byte[] rawVgmData)
{
    //Convert
    int current_pos;
    int loop_ofs;
    int begin_ofs;
    int vgmLen = rawVgmData.Length;

    current_pos = 0x100;
    loop_ofs = 0x100;
    begin_ofs = 0x100;

    if (rawVgmData[0x08] < 50 && rawVgmData[0x09] == 1)
    {
        // below 1.50
        begin_ofs = current_pos = 0x40;
    }
    else
    {
        // begin ofs is always 0x40 in VGM ver < 1.50
        begin_ofs = rawVgmData[0x37] << 24 | rawVgmData[0x36] << 16 | rawVgmData[0x35] << 8 | rawVgmData[0x34];
        begin_ofs += 0x34; // = 0x80 or 0x100.
                           //Console.WriteLine($"ABS Ofs of beginning 0x{begin_ofs:X8}");
        if (begin_ofs != 0x100)
            current_pos = begin_ofs;
    }

    // calc loop ofs
    int relofs = rawVgmData[0x1f] << 24 | rawVgmData[0x1e] << 16 | rawVgmData[0x1d] << 8 | rawVgmData[0x1c];
    if (relofs == 0)
    {
        //loop_ofs = begin_ofs;
    }
    else
    {
        relofs += 0x1C; // relofs into file ofs
                        //Console.WriteLine($"Loop Point Rel 0x{relofs - 0x1C:X8} Abs 0x{relofs:X8}");
        if (relofs == 0x1C)
        {
            // No Loop!
            //loop_ofs = begin_ofs;
            relofs = 0;
        }
        else
        {
            loop_ofs = relofs;
        }
    }

    //PSG/FM EN
    if (rawVgmData[3] != 0 && rawVgmData[4] != 0)
        cnvVgmData.Add(0x3);
    else if (rawVgmData[3] != 0 && rawVgmData[4] == 0)
        cnvVgmData.Add(0x0);
    else if (rawVgmData[3] == 0 && rawVgmData[4] != 0)
        cnvVgmData.Add(0x1);

    int newLoop = -1;
    int waitN = 0;
    while (true)
    {
        if (relofs != 0 && current_pos == loop_ofs)
            newLoop = cnvVgmData.Count;

        var cmd = rawVgmData[current_pos++];
        if (cmd != 0xff)
        {
            switch (cmd)
            {
                case 0x4f:
                    writeWaitAndData(cnvVgmData, 0x39, waitN);
                    waitN = 0;
                    cnvVgmData.Add(rawVgmData[current_pos++]);
                    break;
                case 0x50:  //PSG
                    writeWaitAndData(cnvVgmData, 0x3a, waitN);
                    waitN = 0;
                    cnvVgmData.Add(rawVgmData[current_pos++]);
                    break;
                case 0x51:  //OPLL
                    writeWaitAndData(cnvVgmData, rawVgmData[current_pos++], waitN);
                    waitN = 0;
                    cnvVgmData.Add(rawVgmData[current_pos++]);
                    break;
                case 0x61:  //WAIT
                    waitN += (rawVgmData[current_pos++] + (rawVgmData[current_pos++] << 8)) / 735;
                    break;
                case 0x62:  //WAIT
                case 0x63:  //WAIT
                    waitN++;
                    break;
                case 0x66:
                    if (waitN > 0)
                    {
                        writeWait(cnvVgmData, waitN);
                        waitN = 0;
                    }

                    cmd = 0xff;
                    if (relofs == 0)
                        cnvVgmData.Add(0x8f);
                    else
                    {
                        cnvVgmData.Add(0x8e);
                        cnvVgmData.Add((byte)(newLoop & 0xff));
                        cnvVgmData.Add((byte)((newLoop >> 8) & 0xff));
                    }
                    break;
                default:
                    Console.WriteLine("Unknown command: " + cmd);
                    break;
            }
        }
        if (cmd == 0xff)
            break;
    }
    return newLoop;
}