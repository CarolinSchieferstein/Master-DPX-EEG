# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20
#
# --- eeg pre-processing for dpx-r40
# --- version: march 2020
#
# --- import data, crate info for file
# --- save to .fif

# ========================================================================
# ------------------- import relevant extensions -------------------------
from os import mkdir
import os.path as op
import glob
import re

from mne import read_epochs

# ========================================================================
# --- global settings
# prompt user to set project path
root_path = input("Type path to project directory: ")

# look for directory
if op.isdir(root_path):
    print('Setting "root_path" to ', root_path)
else:
    raise NameError('Directory not found!')

# path to eeg files
data_path = op.join(root_path, 'derivatives/epochs')
# output path
output_path = op.join(root_path, 'derivatives/rt')
output_path_amp = op.join(root_path, 'derivatives/amp')

# create directory for save
if not op.isdir(op.join(output_path)):
    mkdir(op.join(output_path))

if not op.isdir(op.join(output_path_amp)):
    mkdir(op.join(output_path_amp))

# files to be analysed

files = sorted(glob.glob(op.join(data_path, 'sub-*', '*cues-epo.fif')))

# === LOOP THROUGH FILES AND EXTRACT EPOCHS =========================
for file in files:
    # --- 1) set up paths and file names -----------------------
    filepath, filename = op.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0]

    # --- 2) Read in the data ----------------------------------
    # import cue epochs
    cue_epochs = read_epochs(file, preload=True)

    # --- 3) Extract metadata ----------------------------------
    rt = cue_epochs.metadata

    # add subject id
    rt = rt.assign(subject=subj)

    # --- 4) export rois
    cue_epochs = cue_epochs.apply_baseline((-0.300, -0.050))

    df = cue_epochs.to_data_frame(long_format=True)

    # get tim rois
    n170 = df[((df["time"] >= 100) & (df["time"] <= 200))
              & ((df["channel"] == 'PO8') | (df["channel"] == 'PO7'))]
    n170 = n170.assign(subject=subj)

    p300 = df[((df["time"] >= 250) & (df["time"] <= 500))
              & ((df["channel"] == 'Pz') | (df["channel"] == 'CPz'))]
    p300 = p300.assign(subject=subj)

    cnv = df[((df["time"] >= 900) & (df["time"] <= 1500))
             & (df["channel"] == 'FC2')]
    cnv = cnv.assign(subject=subj)

    # --- 4) Save file -----------------------------------------
    # create directory for save
    if not op.exists(op.join(output_path, 'sub-%s' % subj)):
        mkdir(op.join(output_path, 'sub-%s' % subj))

    if not op.exists(op.join(output_path_amp, 'sub-%s' % subj)):
        mkdir(op.join(output_path_amp, 'sub-%s' % subj))

    # save to disk
    rt.to_csv(op.join(output_path, 'sub-%s' % subj,
                      'sub-%s-rt.tsv' % subj),
              sep='\t',
              index=False)

    n170.to_csv(op.join(output_path_amp, 'sub-%s' % subj,
                        'sub-%s-n170.tsv' % subj),
                sep='\t',
                index=False)
    p300.to_csv(op.join(output_path_amp, 'sub-%s' % subj,
                        'sub-%s-p300.tsv' % subj),
                sep='\t',
                index=False)
    cnv.to_csv(op.join(output_path_amp, 'sub-%s' % subj,
                       'sub-%s-cnv.tsv' % subj),
               sep='\t',
               index=False)
