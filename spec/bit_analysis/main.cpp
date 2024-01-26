#include <iostream>
#include <fstream>
#include <vector>
#include <cstdio>
#include <string.h>
#include <stdexcept>

using namespace std;

struct WAVEFILEHEADER
{
    char ChunkId[4];
    int ChunkSize;
    char Format[4];
    char SubChunkFmt[4];
    int SubChunkFmtSize;
    short int AudioFormat;
    short int NumChannels;

    int SampleRate;
    int ByteRate;
    short int BlockAlign;
    short int BitsPerSample;

    char ChunkData[4];
    int SubChunkDataSize;
};

void filter(const vector<short> &din, vector<short> &dout, vector<double> coef)
{

    for (int i = 0; i < din.size(); i++)
    {
        for (int j = 0; j < coef.size(); j++)
        {
            if (i - j < 0)
            {
                continue;
            }

            dout[i] += din[i - j] * coef[j];
        }
    }
}

void echo(char *path)
{

    fstream filin(path, ios::in | ios::binary);
    WAVEFILEHEADER wav;
    filin.read((char *)&wav, sizeof(wav));

    fstream fileout("output_echo.wav", ios::out | ios::binary);
    int echo_rate = 10000;

    /* dataChunkSize is the total number of bytes of audio data. Each byte is 8 bits.
       Since we need 16 bit integer (short) for storing the audio sample value, the total number of samples
       are dataChunkSize / 2
    */
    const auto totalNumberOfSamples = wav.SubChunkDataSize / 2;

    // Initialize a vector container for storing all the audio samples and read data to it.
    vector<short> x; // data from the input WAV file
    vector<short> y; // data that is going to be processed and written to a new output WAV file

    x.resize(totalNumberOfSamples);
    y.resize(totalNumberOfSamples);

    filin.read((char *)x.data(), wav.ChunkSize);

    for (int i = 0; i < totalNumberOfSamples; i++)
    {
        y[i] = 0.2 * x[i] + 0.2 * x[i - echo_rate];
    }

    fileout.write((char *)&wav, sizeof(wav));       // write the header to output file
    fileout.write((char *)y.data(), wav.ChunkSize); // Write the modified data into a new file
    filin.close();
    fileout.close();
}

WAVEFILEHEADER load_data(char *path, char *type_of_filter, vector<short> &din, vector<double> &coef)
{
    WAVEFILEHEADER wav;
    fstream filin(path, ios::in | ios::binary);
    fstream bit_analysis_input;

    filin.read((char *)&wav, sizeof(wav));

    /* dataChunkSize is the total number of bytes of audio data. Each byte is 8 bits.
       Since we need 16 bit integer (short) for storing the audio sample value, the total number of samples
       are dataChunkSize / 2
    */
    const auto totalNumberOfSamples = wav.SubChunkDataSize / 2;

    din.resize(totalNumberOfSamples);

    filin.read((char *)din.data(), wav.ChunkSize);

    filin.close();

    // to display the contents of the header
    string coef_file_name;

    if (strcmp(type_of_filter, "LPF") == 0 || strcmp(type_of_filter, "2") == 0)
    {
        coef_file_name = "lpf.txt";
    }
    if (strcmp(type_of_filter, "BPF") == 0 || strcmp(type_of_filter, "3") == 0)
    {
        coef_file_name = "bpf.txt";
    }
    if (strcmp(type_of_filter, "HPF") == 0 || strcmp(type_of_filter, "4") == 0)
    {
        coef_file_name = "hpf.txt";
    }

    ifstream myfile;
    string str;
    myfile.open(coef_file_name);
    if (myfile.is_open())
    {
        while (getline(myfile, str))
        {
            coef.push_back(stod(str));
        }
    }
    return wav;
}

int main(int argc, char *argv[])
{
    WAVEFILEHEADER wav;
    vector<short> din;  // data from the input WAV file
    vector<short> dout; // data that is going to be processed and written to a new output WAV file
    vector<double> coef;
    fstream bit_analysis_input;  // file for bit_analysis_input
    fstream bit_analysis_output; // file for bit analysis output
    char *selectedEffect;
    char *file_path;

    if (argc < 2)
    {
        cout << "Not enough arguments, please enter the path of the destination file" << endl;
        return -1;
    }
    else
    {
        file_path = argv[1];
    }

    if (argc < 3)
    {
        char select;

        cout << "Please select 1-4 for desired effect:\n 1.echo\n 2.LPF\n 3.BPF\n 4.HPF\n\n";
        cin >> select;

        if (select == '1')
        {
            echo(file_path);
            return 0;
        }
        if (select == '2')
            selectedEffect = (char *)"LPF";
        if (select == '3')
            selectedEffect = (char *)"BPF";
        if (select == '4')
            selectedEffect = (char *)"HPF";
    }
    if (argc == 3)
    {

        if (argv[2] != string("echo") && argv[2] != string("LPF") && argv[2] != string("BPF") && argv[2] != string("HPF"))
        {
            cout << "Please enter one of the following words: echo, LPF, BPF, HPF" << endl;
            return 0;
        }
        if (strcmp(argv[2], "echo") == 0)
        {
            echo(file_path);
            return 0;
        }
        else
        {
            selectedEffect = (char *)argv[2];
        }
    }

    wav = load_data(file_path, selectedEffect, din, coef);

    bit_analysis_input.open("vector_input.txt", ios_base::out);

    for (int i = 0; i < din.size(); i++)
    {
        bit_analysis_input << din[i] << endl;
    }

    bit_analysis_input.close();

    dout.resize(wav.SubChunkDataSize / 2);

    filter(din, dout, coef);

    fstream output("filtered_output.wav", ios::out | ios::binary);
    output.write((char *)&wav, sizeof(wav));          // write the header to output file
    output.write((char *)dout.data(), wav.ChunkSize); // Write the modified data into a new file
    output.close();
    bit_analysis_output.open("vector_output.txt", ios_base::out);

    for (int i = 0; i < dout.size(); i++)
    {
        bit_analysis_output << dout[i] << endl;
    }

    bit_analysis_output.close();

    return 0;
}
