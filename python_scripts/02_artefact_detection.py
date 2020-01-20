# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20
#
# --- eeg pre-processing for DPX R40
# --- version: dez 2019
#
# --- detect and annotate artifact distorted segments in continuous data,
# --- average reference

# ========================================================================
# ------------------- import relevant extensions -------------------------
import os.path as op
from os import mkdir
from glob import glob

from re import findall
import numpy as np
import pandas as pd

from mne.io import read_raw_fif
from mne import pick_types, Annotations

# ========================================================================
# --- global settings
# --- prompt user to set project path
root_path = input("Type path to project directory: ")

# look for directory
if op.isdir(root_path):
    print("Setting 'root_path' to ", root_path)
else:
    raise NameError('Directory not found!')

# derivatives path
derivatives_path = op.join(root_path, 'derivatives')

# path to eeg files
data_path = op.join(derivatives_path, 'extract_blocks')

# create directory for output
if not op.isdir(op.join(derivatives_path, 'artifact_detection')):
    mkdir(op.join(derivatives_path, 'artifact_detection'))

# path for saving output
output_path = op.join(derivatives_path, 'artifact_detection')

# files to be analysed
files = sorted(glob(op.join(data_path, 'sub-*', '*-raw.fif')))

# ========================================================================
# ----------- loop through files and detect artifacts --------------------
for file in files:

    # --- 1) set up paths and file names -----------------------
    file_path, filename = op.split(file)
    # subject in question
    subj = findall(r'\d+', filename)[0].rjust(3, '0')

    # --- 2) import the preprocessed data ----------------------
    raw = read_raw_fif(file, preload=True)

    # index of eogs and stim channels
    picks_no_eeg = pick_types(raw.info,
                              eeg=False,
                              eog=True,
                              stim=True)

    # channels which are of type "eeg"
    picks_eeg = pick_types(raw.info,
                           eeg=True,
                           eog=False,
                           stim=False)

    # channel names
    channels = raw.info['ch_names']

    # sampling frequency
    sfreq = raw.info['sfreq']

    # channels that should be ignored during the artifact detection procedure
    ignore_ch = {'Fp1', 'Fpz', 'Fp2', 'AF7', 'AF3', 'AFz', 'AF4', 'AF8'}
    # update dict
    ignore_ch.update({raw.info['ch_names'][chan] for chan in picks_no_eeg})

    # --- 3.1) filter the data ---------------------------------
    # copy the file
    raw_copy = raw.copy()
    # apply filter
    raw_copy = raw_copy.filter(l_freq=0.1, h_freq=40.0,
                               picks=['eeg', 'eog'],
                               filter_length='auto',
                               l_trans_bandwidth='auto',
                               h_trans_bandwidth='auto',
                               method='fir',
                               phase='zero',
                               fir_window='hamming',
                               fir_design='firwin')

    # --- 3.2) find distorted segments in data -----------------
    # copy of data
    data = raw_copy.get_data(picks_eeg)

    # channels to be checked by artifact detection procedure
    ch_ix = [channels.index(ch) for ch in channels if ch not in ignore_ch]

    # detect artifacts (i.e., absolute amplitude > 500 microV)
    times = []
    annotations_df = pd.DataFrame(times)
    onsets = []
    duration = []
    annotated_channels = []
    bad_chans = []

    # loop through samples
    for sample in range(0, data.shape[1]):
        if len(times) > 0:
            if sample <= (times[-1] + int(1 * sfreq)):
                continue
        peak = []
        for channel in ch_ix:
            peak.append(abs(data[channel][sample]))
        if max(peak) >= 200e-6:
            times.append(float(sample))
            annotated_channels.append(channels[ch_ix[int(np.argmax(peak))]])
    # if artifact found create annotations for raw data
    if len(times) > 0:
        # get first time
        first_time = raw_copy._first_time
        # column names
        annot_infos = ['onset', 'duration', 'description']

        # save onsets
        onsets = np.asarray(times)
        # include one second before artifact onset
        onsets = ((onsets / sfreq) + first_time) - 1
        # durations and labels
        duration = np.repeat(2, len(onsets))
        description = np.repeat('Bad', len(onsets))

        # get annotations in data
        artifacts = np.array((onsets, duration, description)).T
        # to pandas data frame
        artifacts = pd.DataFrame(artifacts,
                                 columns=annot_infos)
        # annotations from data
        annotations = pd.DataFrame(raw_copy.annotations)
        annotations = annotations[annot_infos]

        # merge artifacts and previous annotations
        artifacts = artifacts.append(annotations, ignore_index=True)

        # create new annotation info
        annotations = Annotations(artifacts['onset'],
                                  artifacts['duration'],
                                  artifacts['description'],
                                  orig_time=raw_copy.annotations.orig_time)
        # apply to raw data
        raw_copy.set_annotations(annotations)

    # save total annotated time
    total_time = sum(duration)
    # save frequency of annotation per channel
    frequency_of_annotation = {x: annotated_channels.count(x)*2
                               for x in annotated_channels}
    # if exceeds 0.9% of total time --> mark as bad channel
    threshold = raw_copy.times[-1] * .01

    # save bads in info structure
    bad_chans = [chan for chan, value in frequency_of_annotation.items()
                 if value >= int(threshold)]
    raw_copy.info['bads'] = bad_chans

    # --- 3.3) plot data and check for inconsistencies  ----------
    raw_copy.plot(scalings=dict(eeg=50e-6),
                  n_channels=len(raw.info['ch_names']),
                  bad_color='red',
                  block=True)

    # save bad channels for summary
    interpolated = raw_copy.info['bads'].copy()

    # --- if bad channels were found, repeat preprocessing ---------
    if bad_chans:
        # re-run artifact detection
        raw_copy = raw.copy()
        raw_copy.info['bads'] = bad_chans

        # interpolate bads
        raw_copy.interpolate_bads(reset_bads=True,
                                  verbose=False,
                                  mode='accurate')

        # apply filter
        raw_copy = raw_copy.filter(l_freq=0.1, h_freq=40.0,
                                   picks=['eeg', 'eog'],
                                   filter_length='auto',
                                   l_trans_bandwidth='auto',
                                   h_trans_bandwidth='auto',
                                   method='fir',
                                   phase='zero',
                                   fir_window='hamming',
                                   fir_design='firwin')

        # --- find distorted segments in data ----------------------
        # copy of data
        data = raw_copy.get_data(picks_eeg)

        # channels to be checked by artifact detection procedure
        ch_ix = [channels.index(chan) for chan in channels
                 if chan not in ignore_ch]

        # detect artifacts (i.e., absolute amplitude > 500 microV)
        times = []
        annotations_df = pd.DataFrame(times)
        onsets = []
        duration = []
        annotated_channels = []
        bad_chans = []

        # loop through samples
        for sample in range(0, data.shape[1]):
            if len(times) > 0:
                if sample <= (times[-1] + int(1 * sfreq)):
                    continue
            peak = []
            for channel in ch_ix:
                peak.append(abs(data[channel][sample]))
            if max(peak) >= 200e-6:
                times.append(float(sample))
                annotated_channels.append(channels[ch_ix[int(np.argmax(peak))]])
        # if artifact found create annotations for raw data
        if len(times) > 0:
            # get first time
            first_time = raw_copy._first_time
            # column names
            annot_infos = ['onset', 'duration', 'description']

            # save onsets
            onsets = np.asarray(times)
            # include one second before artifact onset
            onsets = ((onsets / sfreq) + first_time) - 1
            # durations and labels
            duration = np.repeat(2, len(onsets))
            description = np.repeat('Bad', len(onsets))

            # get annotations in data
            artifacts = np.array((onsets, duration, description)).T
            # to pandas data frame
            artifacts = pd.DataFrame(artifacts,
                                     columns=annot_infos)
            # annotations from data
            annotations = pd.DataFrame(raw_copy.annotations)
            annotations = annotations[annot_infos]

            # merge artifacts and previous annotations
            artifacts = artifacts.append(annotations, ignore_index=True)

            # create new annotation info
            annotations = Annotations(artifacts['onset'],
                                      artifacts['duration'],
                                      artifacts['description'],
                                      orig_time=raw_copy.annotations.orig_time)
            # apply to raw data
            raw_copy.set_annotations(annotations)

    # --- 4) re-reference data to average of 64 electrodes  ----
    raw_copy.set_eeg_reference(ref_channels='average',
                               projection=True)

    # --- 5) plot data and check for inconsistencies  ----------
    raw_copy.plot(scalings=dict(eeg=50e-6),
                  n_channels=len(raw.info['ch_names']),
                  bad_color='red',
                  block=True)

    # --- 6) save segmented data  -----------------------------
    # create directory for save
    if not op.exists(op.join(output_path, 'sub-%s' % subj)):
        mkdir(op.join(output_path, 'sub-%s' % subj))

    # save file
    raw_copy.save(op.join(output_path, 'sub-%s' % subj,
                          'sub-%s_artifact_detection-raw.fif' % subj),
                  overwrite=True)

    # write summary
    name = 'sub-%s_artifact_detection.txt' % subj
    sfile = open(op.join(output_path, 'sub-%s', name) % subj, 'w')
    # channels info
    sfile.write('Channels_interpolated:\n')
    for ch in interpolated:
        sfile.write('%s\n' % ch)
    # frequency of annotation
    sfile.write('Frequency_of_annotation:\n')
    for ch, f in frequency_of_annotation.items():
        sfile.write('%s, %f\n' % (ch, f))
    sfile.write('total_annotated:\n')
    sfile.write(str(round(total_time / raw_copy.times[-1], 3) * 100) + ' %\n')
    sfile.close()

    del raw, raw_copy
