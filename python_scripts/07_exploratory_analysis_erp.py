# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- Python 3.7 / mne 0.20.4
#
# --- eeg analysis processing for dpx-r40
# --- version: may 2020
#
# --- compute erps
# --- save figures
import glob
import os
import re

import numpy as np

from scipy import stats

import matplotlib.pyplot as plt
import matplotlib.cm as cm
from mpl_toolkits.axes_grid1 import make_axes_locatable
from matplotlib.colorbar import ColorbarBase
from matplotlib.colors import Normalize

from mne import read_epochs, combine_evoked, grand_average
from mne.channels import make_1020_channel_selections
from mne.viz import plot_compare_evokeds

###############################################################################
# prompt user to set project path
root_path = input("Type path to project directory: ")

# look for directory
if os.path.isdir(root_path):
    print('Setting "root_path" to ', root_path)
else:
    raise NameError('Directory not found!')

# path to eeg files
data_path = os.path.join(root_path, 'derivatives/epochs')

# cue files to be analysed
cue_files = sorted(glob.glob(
    os.path.join(data_path, 'sub-*', '*cues-epo.fif')))
# probes files to be analysed
probe_files = sorted(glob.glob(
    os.path.join(data_path, 'sub-*', '*probes-epo.fif')))


###############################################################################
# from https://github.com/JoseAlanis/supplementary_dpx_tt/blob/master/stats.py
# by Jose Alanis
def within_subject_cis(insts, ci=0.95):
    # see Morey (2008): Confidence Intervals from Normalized Data:
    # A correction to Cousineau (2005)

    # the type of the provided instances should be the same
    if not all(isinstance(inst, (dict, list)) for inst in insts):
        raise ValueError('instances must be of same type (either dict ot list)')

    # the number of subjects should be the same
    n_subj = np.unique([len(i) for i in insts])
    if len(n_subj) > 1:
        raise ValueError('inst must be of same length')

    if isinstance(insts[0], dict):
        subjs = insts[0].keys()
    else:
        subjs = np.arange(0, len(insts[0]))

    # correction factor for number of conditions
    n_cond = len(insts)
    corr_factor = np.sqrt(n_cond / (n_cond - 1))

    # compute overall subject ERPs
    subject_erp = {subj: grand_average([insts[cond][subj]
                                        for cond in range(n_cond)])
                   for subj in subjs}

    # compute condition grand averages
    grand_averages = [grand_average(list(cond.values()))
                      for cond in insts]

    # place holder for results
    n_channels = grand_averages[0].data.shape[0]
    n_times = grand_averages[0].data.shape[1]
    norm_erps = np.zeros((n_cond, int(n_subj), n_channels, n_times))

    # compute normed ERPs,
    # ((condition ERP - subject ERP) + grand average) * corr_factor
    for n_s, subj in enumerate(subjs):

        for ic, cond in enumerate(insts):
            erp_data = cond[subj].data.copy() - subject_erp[subj].data
            erp_data = (erp_data + grand_averages[ic].data) * corr_factor

            norm_erps[ic, n_s, :] = erp_data

    erp_sem = np.zeros((n_cond, n_channels, n_times))
    for n_c in range(n_cond):
        erp_sem[n_c, :] = stats.sem(norm_erps[n_c, :], axis=0)

    confidence = np.zeros((n_cond, n_channels, n_times))

    for n_c in range(n_cond):
        confidence[n_c, :] = erp_sem[n_c, :] * \
                             stats.t.ppf((1 + ci) / 2.0, int(n_subj) - 1)

    return confidence


###############################################################################
# 1) dicts for storing individual sets of epochs/ERPs
a_cues = dict()
b_cues = dict()
a_erps = dict()
b_erps = dict()

a_erps_rew = dict()
a_erps_no_rew = dict()
b_erps_rew = dict()
b_erps_no_rew = dict()

# baseline to be applied
baseline = (-0.300, -0.050)

###############################################################################
# 2) Loop through files and import the desired epochs
for file in cue_files:
    cue_epo = read_epochs(file, preload=True)
    cue_epo.resample(sfreq=100.)

    # subject in question
    filepath, filename = os.path.split(file)
    subj = re.findall(r'\d+', filename)[0].rjust(3, '0')

    a_cues['subj_%s' % subj] = cue_epo['Correct A'].apply_baseline(baseline)
    b_cues['subj_%s' % subj] = cue_epo['Correct B'].apply_baseline(baseline)

    # compute ERP
    a_erps['subj_%s' % subj] = a_cues['subj_%s' % subj].average()
    b_erps['subj_%s' % subj] = b_cues['subj_%s' % subj].average()

    a_erps_rew['subj_%s' % subj] = a_cues['subj_%s' % subj]['reward == 1'].average()
    a_erps_no_rew['subj_%s' % subj] = a_cues['subj_%s' % subj]['reward == 0'].average()

    b_erps_rew['subj_%s' % subj] = b_cues['subj_%s' % subj]['reward == 1'].average()
    b_erps_no_rew['subj_%s' % subj] = b_cues['subj_%s' % subj]['reward == 0'].average()

###############################################################################
# 3) compute grand averages
ga_a_cue = grand_average(list(a_erps.values()))
ga_b_cue = grand_average(list(b_erps.values()))

ga_a_rew = grand_average(list(a_erps_rew.values()))
ga_b_rew = grand_average(list(b_erps_rew.values()))

ga_a_norew = grand_average(list(a_erps_no_rew.values()))
ga_b_norew = grand_average(list(b_erps_no_rew.values()))

###############################################################################
# 4) plot global field power
gfp_times = {'t1': [0.07, 0.06],
             't2': [0.13, 0.10],
             't3': [0.23, 0.12],
             't4': [0.35, 0.09],
             't5': [0.44, 0.22],
             't6': [1.70, 0.30]}

# create evokeds dict
evokeds = {'Cue A': ga_a_cue.copy().crop(tmin=-0.25),
           'Cue B': ga_b_cue.copy().crop(tmin=-0.25)}

# use viridis colors
colors = np.linspace(0, 1, len(gfp_times.values()))
cmap = cm.get_cmap('viridis')
# plot GFP and save figure
fig, ax = plt.subplots(figsize=(8, 3))
plot_compare_evokeds(evokeds,
                     axes=ax,
                     linestyles={'Cue A': '-', 'Cue B': '--'},
                     styles={'Cue A': {"linewidth": 2.0},
                             'Cue B': {"linewidth": 2.0}},
                     ylim=dict(eeg=[-0.1, 4]),
                     colors={'Cue A': 'k', 'Cue B': 'crimson'},
                     show=True)
ax.set_xticks(list(np.arange(-.25, 2.55, 0.25)), minor=False)
ax.set_yticks(list(np.arange(0, 5, 1)), minor=False)
# annotate the gpf plot and tweak it's appearance
for i, val in enumerate(gfp_times.values()):
    ax.bar(val[0], 5, width=val[1], alpha=0.20,
           align='edge', color=cmap(colors[i]))
ax.annotate('t1', xy=(0.070, 4.), weight="bold")
ax.annotate('t2', xy=(0.155, 4.), weight="bold")
ax.annotate('t3', xy=(0.260, 4.), weight="bold")
ax.annotate('t4', xy=(0.360, 4.), weight="bold")
ax.annotate('t5', xy=(0.500, 4.), weight="bold")
ax.annotate('t6', xy=(1.800, 4.), weight="bold")

ax.legend(loc='upper center', framealpha=1)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_bounds(0, 4)
ax.spines['bottom'].set_bounds(-0.25, 2.5)
ax.xaxis.set_label_coords(0.5, -0.175)
ax.axvline(x=2.0, ymin=-5, ymax=5,
           color='black', linestyle='dashed', linewidth=.8)
fig.subplots_adjust(bottom=0.2)
fig.savefig(root_path + '/derivatives/results/GFP_evoked_cues.pdf', dpi=300)


###############################################################################
# 5) plot condition ERPs
# arguments fot the time-series maps
ts_args = dict(gfp=False,
               time_unit='s',
               ylim=dict(eeg=[-10, 10]),
               xlim=[-.25, 2.5])

# times to plot
ttp = [0.10, 0.17, 0.30, 0.56, 0.75, 1.85]
# arguments fot the topographical maps
topomap_args = dict(sensors=False,
                    time_unit='s',
                    vmin=8, vmax=-8,
                    average=0.05,
                    extrapolate='head')

# plot activity pattern evoked by the cues
for evoked in evokeds:
    title = evoked.replace("_", " ") + ' (64 EEG channels)'
    fig = evokeds[evoked].plot_joint(ttp,
                                     ts_args=ts_args,
                                     topomap_args=topomap_args,
                                     title=title,
                                     show=True)
    fig.axes[-1].texts[0]._fontproperties._size=12.0  # noqa
    fig.axes[-1].texts[0]._fontproperties._weight='bold'  # noqa
    fig.axes[0].set_xticks(list(np.arange(-.25, 2.55, .25)), minor=False)
    fig.axes[0].set_yticks(list(np.arange(-8, 8.5, 4)), minor=False)
    fig.axes[0].axhline(y=0, xmin=-.5, xmax=2.5,
                        color='black', linestyle='dashed', linewidth=.8)
    fig.axes[0].axvline(x=0, ymin=-5, ymax=5,
                        color='black', linestyle='dashed', linewidth=.8)
    fig.axes[0].axvline(x=2.0, ymin=-5, ymax=5,
                        color='black', linestyle='dashed', linewidth=.8)
    fig.axes[0].spines['top'].set_visible(False)
    fig.axes[0].spines['right'].set_visible(False)
    fig.axes[0].spines['left'].set_bounds(-8, 8)
    fig.axes[0].spines['bottom'].set_bounds(-.25, 2.5)
    fig.axes[0].xaxis.set_label_coords(0.5, -0.2)
    w, h = fig.get_size_inches()
    fig.set_size_inches(w * 1.15, h * 1.15)
    fig_name = root_path + '/derivatives/results/Evoked_%s.pdf' % evoked.replace(' ', '_')  # noqa
    fig.savefig(fig_name, dpi=300)


###############################################################################
# 6) plot difference wave (Cue B - Cue A)

# compute difference wave
ab_diff = combine_evoked([ga_b_cue, -ga_a_cue], weights='equal')

selections = make_1020_channel_selections(ga_a_cue.info, midline='12z')

fig, ax = plt.subplots(nrows=1, ncols=3, figsize=(20, 5))
for s, selection in enumerate(selections):
    picks = selections[selection]

    mask = abs(ab_diff.data) > 1.0e-6

    ab_diff.plot_image(xlim=[-0.25, 2.5],
                       picks=picks,
                       clim=dict(eeg=[-5, 5]),
                       colorbar=False,
                       axes=ax[s],
                       mask=mask,
                       mask_cmap='RdBu_r',
                       mask_alpha=0.5,
                       show=False)
    # tweak plot appearance
    if selection in {'Left', 'Right'}:
        title = selection + ' hemisphere'
    else:
        title = 'Midline'
    ax[s].title._text = title # noqa
    ax[s].set_ylabel('Channels', labelpad=10.0,
                     fontsize=11.0, fontweight='bold')

    ax[s].set_xlabel('Time (s)',
                     labelpad=10.0, fontsize=11.0, fontweight='bold')

    ax[s].set_xticks(list(np.arange(-.25, 2.55, .25)), minor=False)
    ax[s].set_yticks(np.arange(len(picks)), minor=False)
    labels = [ga_a_cue.ch_names[i] for i in picks]
    ax[s].set_yticklabels(labels, minor=False)
    ax[s].spines['top'].set_visible(False)
    ax[s].spines['right'].set_visible(False)
    ax[s].spines['left'].set_bounds(-0.5, len(picks)-0.5)
    ax[s].spines['bottom'].set_bounds(-.25, 2.5)
    ax[s].texts = []

    # add intercept line (at 0 s) and customise figure boundaries
    ax[s].axvline(x=0, ymin=0, ymax=len(picks),
                  color='black', linestyle='dashed', linewidth=1.0)
    ax[s].axvline(x=2.0, ymin=0, ymax=len(picks),
                  color='black', linestyle='dashed', linewidth=1.0)

    colormap = cm.get_cmap('RdBu_r')
    orientation = 'vertical'
    norm = Normalize(vmin=-5.0, vmax=5.0)
    divider = make_axes_locatable(ax[s])
    cax = divider.append_axes('right', size='2.5%', pad=0.2)
    cbar = ColorbarBase(cax, cm.get_cmap('RdBu_r'),
                        ticks=[-5.0, 0., 5.0], norm=norm,
                        label=r'Difference B-A ($\mu$V)',
                        orientation=orientation)
    cbar.outline.set_visible(False)
    cbar.ax.set_frame_on(True)
    label = r'Difference B-A (in $\mu V$)'
    for key in ('left', 'top',
                'bottom' if orientation == 'vertical' else 'right'):
        cbar.ax.spines[key].set_visible(False)

    fig.subplots_adjust(
        left=0.05, right=0.95, bottom=0.15, wspace=0.3, hspace=0.25)

# save figure
fig.savefig(root_path + '/derivatives/results/Diff_A-B_image.pdf', dpi=300)


###############################################################################
# 6) plot compare Cue B and Cue A

cis = within_subject_cis([a_erps, b_erps])

for electrode in ['AF7', 'AF8', 'FCz', 'FC2', 'FC3', 'Cz', 'CPz', 'PO7','PO8']:
    pick = ga_a_cue.ch_names.index(electrode)

    fig, ax = plt.subplots(figsize=(8, 4))
    plot_compare_evokeds({'Cue A': ga_a_cue.copy().crop(-0.25, 2.5),
                          'Cue B': ga_b_cue.copy().crop(-0.25, 2.5)},
                         vlines=[],
                         picks=pick,
                         invert_y=False,
                         ylim=dict(eeg=[-8.5, 8.5]),
                         colors={'Cue A': 'k', 'Cue B': 'crimson'},
                         axes=ax,
                         truncate_xaxis=False,
                         show_sensors='upper right',
                         show=False)
    ax.axhline(y=0, xmin=-.25, xmax=2.5,
               color='black', linestyle='dotted', linewidth=.8)
    ax.axvline(x=0, ymin=-8.5, ymax=8.5,
               color='black', linestyle='dotted', linewidth=.8)
    ax.fill_between(ga_a_cue.times,
                    (ga_a_cue.data[pick] + cis[0, pick, :]) * 1e6,
                    (ga_a_cue.data[pick] - cis[0, pick, :]) * 1e6,
                    alpha=0.2,
                    color='k')
    ax.fill_between(ga_b_cue.times,
                    (ga_b_cue.data[pick] + cis[1, pick, :]) * 1e6,
                    (ga_b_cue.data[pick] - cis[1, pick, :]) * 1e6,
                    alpha=0.2,
                    color='crimson')
    ax.legend(loc='upper left', framealpha=1)
    ax.set_xlabel('Time (s)', labelpad=10.0, fontsize=11.0)
    ax.set_ylim(-8.5, 8.5)
    ax.set_xticks(list(np.arange(-.25, 2.55, .25)), minor=False)
    ax.set_yticks(list(np.arange(-8, 8.5, 2)), minor=False)
    ax.set_xticklabels([str(lab) for lab in np.arange(-.25, 2.55, .25)],
                       minor=False)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_bounds(-8, 8)
    ax.spines['bottom'].set_bounds(-.25, 2.5)
    ax.axvline(x=2.0, ymin=0, ymax=len(picks),
               color='black', linestyle='dashed', linewidth=1.0)
    fig.subplots_adjust(bottom=0.15)
    fig.savefig(root_path + '/derivatives/results/ERP_AB_%s.pdf' % electrode,
                dpi=300)


cis_rew = within_subject_cis([a_erps_rew, b_erps_rew])

for electrode in ['AF7', 'AF8', 'FCz', 'FC2', 'FC3', 'Cz', 'CPz', 'PO7', 'PO8']:
    pick = ga_a_cue.ch_names.index(electrode)

    fig, ax = plt.subplots(figsize=(8, 4))
    plot_compare_evokeds({'Cue A': ga_a_rew.copy().crop(-0.25, 2.5),
                          'Cue B': ga_b_rew.copy().crop(-0.25, 2.5)},
                         vlines=[],
                         picks=pick,
                         invert_y=False,
                         ylim=dict(eeg=[-8.5, 8.5]),
                         colors={'Cue A': 'k', 'Cue B': 'crimson'},
                         axes=ax,
                         truncate_xaxis=False,
                         show_sensors='upper right',
                         show=False)
    ax.axhline(y=0, xmin=-.25, xmax=2.5,
               color='black', linestyle='dotted', linewidth=.8)
    ax.axvline(x=0, ymin=-8.5, ymax=8.5,
               color='black', linestyle='dotted', linewidth=.8)
    ax.fill_between(ga_a_rew.times,
                    (ga_a_rew.data[pick] + cis[0, pick, :]) * 1e6,
                    (ga_a_rew.data[pick] - cis[0, pick, :]) * 1e6,
                    alpha=0.2,
                    color='k')
    ax.fill_between(ga_b_rew.times,
                    (ga_b_rew.data[pick] + cis[1, pick, :]) * 1e6,
                    (ga_b_rew.data[pick] - cis[1, pick, :]) * 1e6,
                    alpha=0.2,
                    color='crimson')
    ax.legend(loc='upper left', framealpha=1)
    ax.set_xlabel('Time (s)', labelpad=10.0, fontsize=11.0)
    ax.set_ylim(-8.5, 8.5)
    ax.set_xticks(list(np.arange(-.25, 2.55, .25)), minor=False)
    ax.set_yticks(list(np.arange(-8, 8.5, 2)), minor=False)
    ax.set_xticklabels([str(lab) for lab in np.arange(-.25, 2.55, .25)],
                       minor=False)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_bounds(-8, 8)
    ax.spines['bottom'].set_bounds(-.25, 2.5)
    ax.axvline(x=2.0, ymin=0, ymax=len(picks),
               color='black', linestyle='dashed', linewidth=1.0)
    fig.subplots_adjust(bottom=0.15)
    fig.savefig(root_path + '/derivatives/results/ERP_rew_AB_%s.pdf' % electrode,
                dpi=300)
