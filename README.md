# ANTARES

Repository for the analysis of the data collected in the context of the ANTARES study

## Requirements
Clone or download this repository.
Install Python 3.8+ with Pandas and Numpy. Anaconda is a great option.
cd to the repository
run: pip install -r requirements.txt in the command line

## Process STROOP data

Place all the .csv or .txt files in the folder specific by datapath in antares-stroop.py

Execute the script (or the Jupyter notebook)

That's it, the data is exported in the exportfolder specific in antares-stroop.py

## Description of the STROOP task

### Trial distribution
A third of the 72 trials (24) were incongruent trials. There were 18 training trials (12 congruent, 6 incongruent).

## Timings
The duration of the stimuli on the screen was fixed to 1200ms.
The maximum reaction time was fixed to 1200ms (beyond, trial treated as a miss). The feedback was displayed for 700ms. The intertrial interval was uniformly distributed between 700 and 1100ms.

## Description of the columns in STROOPsummarystatistics.csv

For all RT measurements, trials with RTs lower than 150ms were excluded as premature responses.

| Column name  | Column content |
| ------------- | ------------- |
| subject  | self-explanatory  |
| visit  | self-explanatory  |
| rawIntRT  | Raw interference effect on reaction times. RTincongruent-RTcongruent |
| normIntRT  | Normalized interference effect on reaction times. (RTincongruent-RTcongruent)/RTcongruent |
| rawIntRTcor  | rawIntRT computed only with trials in which participants gave a correct response |
| normIntRTcor  | normIntRT computed only with trials in which participants gave a correct response |
| rawIntACC  | Raw interference effect on accuracies. ACCincongruent-ACCcongruent |
| normIntACC  | Normalized interference effect on accuracies. (ACCincongruent-ACCcongruent)/ACCcongruent |
| ACC  | Overall accuracies |
| RT  | Overall reaction times |
| Misses  | Overall frequency of misses (no response) |