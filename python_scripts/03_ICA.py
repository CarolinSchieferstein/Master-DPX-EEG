# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20
#
# --- eeg pre-processing for dpx-r40
# --- version: january 2020
#
# --- import data, crate info for file
# --- save to .fif

# ========================================================================
# ------------------- import relevant extensions -------------------------
import os.path as op
from os import mkdir
import glob
import re

from mne import pick_types
from mne.io import read_raw_fif
from mne.preprocessing import ICA

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
data_path = op.join(root_path, 'derivatives/artifact_detection')
# output path
output_path = op.join(root_path, 'derivatives/ica')

# create directory for save
if not op.isdir(op.join(output_path)):
    mkdir(op.join(output_path))

# files to be analysed
files = sorted(glob.glob(op.join(data_path, 'sub-*', '*-raw.fif')))

# === LOOP THROUGH FILES AND RUN PRE-PROCESSING ==========================
for file in files:

    # --- 1) set up paths and file names -----------------------
    filepath, filename =op.split(file)
    # subject in question
    subj = re.findall(r'\d+', filename)[0]

    # --- 2) READ IN THE DATA ----------------------------------
    # import preprocessed data.
    raw = read_raw_fif(file, preload=True)

    # apply reference
    raw = raw.apply_proj()

    # --- 2) ICA DECOMPOSITION --------------------------------
    # ICA parameters
    n_components = 25
    method = 'picard'
    fit_params = dict(extended=True,
                      ortho=False)
    # decim = None
    reject = dict(eeg=300e-6)

    # Pick electrodes to use
    picks = pick_types(raw.info,
                       meg=False,
                       eeg=True,
                       eog=False,
                       stim=False)

    # ICA parameters
    ica = ICA(n_components=n_components,
              method=method,
              fit_params=fit_params)

    # Fit ICA
    ica.fit(raw.copy().filter(1.0, 40.0),
            picks=picks,
            reject=reject)

    # -- 3) save solution -------------------------------------
    # create directory for save
    if not op.exists(op.join(output_path, 'sub-%s' % subj)):
        mkdir(op.join(output_path, 'sub-%s' % subj))

    # save file
    ica.save(op.join(output_path, 'sub-%s' % subj,
                     'sub-%s-ica.fif' % subj))

    # --- 3) PLOT RESULTING COMPONENTS ------------------------
    # Plot components
    ica_fig = ica.plot_components(picks=range(0, 25), show=True)
    ica_fig.savefig(op.join(output_path, 'sub-%s' % subj,
                            '%s_ica.pdf' % subj))
