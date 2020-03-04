# ---  carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20
#
# --- EEG prepossessing - DPX R40
# --- version march 2020 [WIP]
#
# --- Apply baseline, crop for smaller file, and
# ---Export epochs to .txt

# =================================================================================================
# ------------------------------ Import relevant extensions ---------------------------------------
import mne
import glob
import os

# ========================================================================
# --- GLOBAL SETTINGS
# --- SET PATH TO .epoch-files and output
input_path = '##'
output_path = '##'

# === LOOP THROUGH FILES AND EXPORT EPOCHS ===============================
for file in glob.glob(os.path.join(input_path, '*-epo.fif')):

    filepath, filename = os.path.split(file)
    filename, ext = os.path.splitext(filename)
    name = filename.split('_')[0] + '##'

    # Read epochs
    epochs = mne.read_epochs(file, preload=True)
    # Apply baseline
    epochs.apply_baseline(baseline=(-0.3, -0.1))
    # Only keep time window fro -.3 to .99 sec. around motor response
    small = epochs.copy().crop(tmin=-.3, tmax=.99)

    # Transform to data frame
    epo = small.to_data_frame()
    # Round values
    epo = epo.round(3)
    # Export data frame
    epo.to_csv(output_path + name + '.txt', index=True)
