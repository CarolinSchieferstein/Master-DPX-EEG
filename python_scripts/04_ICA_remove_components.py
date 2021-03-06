# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20
#
# --- eeg pre-processing for dpx-r40
# --- version: february 2020
#
# --- import data, crate info for file
# --- save to .fif

# ========================================================================
# ------------------- import relevant extensions -------------------------
import os
import glob
import re

from mne import find_events, pick_types
from mne.io import read_raw_fif
from mne.preprocessing import read_ica

# ========================================================================
# --- global settings
# prompt user to set project path
root_path = input("Type path to project directory: ")

# look for directory
if os.path.isdir(root_path):
    print('Setting "root_path" to ', root_path)
else:
    raise NameError('Directory not found!')

# path to eeg files
data_path = os.path.join(root_path, 'derivatives/artifact_detection')
# path to eeg files
ica_path = os.path.join(root_path, 'derivatives/ica')
# output path
output_path = os.path.join(root_path, 'derivatives/pruned')

# create directory for save
if not os.path.isdir(os.path.join(output_path)):
    os.mkdir(os.path.join(output_path))

# files to be analysed
files = glob.glob(os.path.join(data_path, 'sub-*', '*-raw.fif'))

for file in files:

    # --- 1) set up paths and file names -----------------------
    filepath, filename = os.path.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0]

    # --- 2) Read in the data ----------------------------------
    raw = read_raw_fif(file, preload=True)

    # --- 4) Import ICA weights --------------------------------
    ica = read_ica(os.path.join(ica_path, 'sub-%s' % subj, 'sub-%s-ica.fif' % subj))

    # --- 5) Plot components time series -----------------------
    # Select bad components for rejection
    ica.plot_sources(raw, title=str(filename),
                     picks=range(0, 25),
                     block=True)

    # Save bad components
    bad_comps = ica.exclude.copy()

    ica.plot_overlay(raw, exclude=bad_comps, picks='eeg')

    # --- 4) Remove bad components -----------------------------
    ica.apply(raw)

    # --- 5) Remove pruned data --------------------------------
    # Plot to check data
    clip = None
    raw.plot(n_channels=66, title=str(filename),
             scalings=dict(eeg=50e-6),
             bad_color='red',
             clipping=clip,
             block=True)

    # --- 6) Write summary about removed components ------------
    # create directory for save
    if not os.path.exists(os.path.join(output_path, 'sub-%s' % subj)):
        os.mkdir(os.path.join(output_path, 'sub-%s' % subj))

    # save summary
    name = '%s_ica_summary' % subj
    file = open(os.path.join(output_path, 'sub-%s' % subj, '%s.txt' % name), 'w')
    # Number of Trials
    file.write('bad components\n')
    for cp in bad_comps:
        file.write('%s\n' % cp)
    # Close file
    file.close()

    # --- 7) Save raw file -----------------------------------
    # Pick electrode to use
    picks = pick_types(raw.info,
                       meg=False,
                       eeg=True,
                       eog=False,
                       stim=True)

    # Save pruned data
    raw.save(os.path.join(output_path, 'sub-%s' % subj, '%s_pruned-raw.fif' % subj),
             picks=picks,
             overwrite=True)
