# ------------------------------ beginn header ------------------------------- #
/*
   authors: cecilia musci & jose c. g. alanis, 2015
   updated: carolin schieferstein & jose. c. g. alan, 2018
   updated: jose. c. g. alanis. 2019

	 encoding: utf-8

   title: scenario file for dot-pattern expectancy task

   see: Barch, D. M., et al., (2008).
        CNTRICS final task selection: working memory.
        Schizophrenia bulletin, 35(1), 136-152.

				Henderson, D., et al., (2012). Optimization of
        a goal maintenance task for use in clinical applications.
			  Schizophrenia Bulletin, 38(1), 104-113.
*/

# program control file
pcl_file = "DPX_Caro_Main.pcl";

# global variables
response_matching = simple_matching;
response_logging = log_active;
active_buttons = 13;
default_background_color = 214,213,213;

# codes for any button press
button_codes = 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113;
# codes for correct button press during the task
target_button_codes = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13;

# ports
default_output_port = 5; 	# response box is default
write_codes = true; 			# send to output device
pulse_width = 3;

# ------------------------------- end header --------------------------------- #
# begin scenario
begin;

# --- start stop signal codes for eeg sub-routine ---
trial{
	   nothing{};
	   code = "DR_Start";
}DR_START;

trial{
	   nothing{};
	   code = "DR_Stopp";
}DR_STOPP;


# --- blank screens and interstimulus & -trial intervals ---


# blank screen
trial {
	trial_type = fixed;
	trial_duration = 500;
	stimulus_event {
		nothing {};
		code = "Blank";
	}blank_event;
}blank_screen;


# --- intro trials and pauses ---
# itro trial for resting state eeg
trial{
	trial_type = fixed;
	trial_duration = 300000;
	stimulus_event{
	picture {
		text{
			font = "Calibri";
			font_size = 20;
			text_align = align_center;
			caption = "Zunächst folgt eine kurze Entspannungsphase (etwa 5 Minuten). \n
			Lehnen Sie sich etwas zuruck und fixieren Sie am besten irgedneinen Punkt vor Ihnen. \n
			Ihre Augen sollten sich währed der Entspannungsphase nicht so stark bewegen. \n
			Also einfach mal zurucklehnen, entspannen und gar nichts tun";
			};
			x = 0; y = 0;};
			code = "RESTING";
		}resting_event;
}intro_resting_state;

# intro text for practice
trial{
	trial_type = first_response;
	trial_duration = forever;
	stimulus_event{
			picture{
			text{
				font = "Helvetica";
				font_size = 30;
				font_color = 0,0,0;
				background_color = 214,213,213;
				caption = "<font size='40'><b>Übungsphase.</b></font> \n \n \n
				Im Folgenden werden Sie die Möglichkeit haben, die Aufgabe einzuüben. \n \n
				Bitte achten Sie darauf, dass Sie bei jedem weißen Punktmuster möglichst schnell eine Antwort abgeben. \n \n \n
				Bei jeder Antwort erhalten Sie eine Rückmeldung, \n
				ob Sie <font color='0,255,0'><b>Richtig</b></font>, <font color='255,0,0'><b>Falsch</b></font>, <font color='0,0,0'><b>zu früh</b></font>, oder <font color='255,185,15'><b>zu langsam</b></font> \n
				geantwortet haben. \n \n \n
				Es geht weiter mit einer beliebigen Taste.";
			}practice_intro_text;
		x = 0;y = 0;};
		code="PRACTICE_INTRO";
	};
}practice_intro;

# continue text for practice
trial{
	trial_type = first_response;
	trial_duration = forever;
	stimulus_event{
			picture{
			text{
				font = "Helvetica";
				font_size = 30;
				font_color = 0,0,0;
				background_color =214,213,213;
				caption = "<font size='40'><b>Übungsphase.</b></font>\n \n \n
				Soweit so gut. Im Folgenden werden Sie die Möglichkeit haben, die Aufgabe weiter einzuüben.\n \n
				Ab jetzt bekommen Sie dennoch keine Rückmeldung Über die Richtigkeit Ihrer Reaktionen.\n
				Lediglig wenn Sie etwas <font color='255,185,15'><b>zu langsam</b></font> reagiert haben.\n
				Verlassen Sie sich einfach auf Ihren Gefühl \n
				und versuchen Sie möglichst schell aber möglichst richtig zu reagiren.\n \n \n
				Wenn Sie so weit sind, können Sie mit einer beliebigen Taste weiter machen.";
			}practice_continue_text;
		x = 0;y = 0;};
		code="PRACTICE_CONTINUE";
	};
}practice_continue;

# intro text for test phase
trial{
	trial_type = first_response;
	trial_duration = forever;
	stimulus_event{
			picture{
			text{
				font = "Helvetica";
				font_size = 30;
				font_color = 0,0,0;
				background_color =214,213,213;
				caption = "<font size='40'><b>Testphase.</b></font>\n \n \n
				In der nächsten Phase, werden Sie dieselbe Aufgabe bearbeiten, die Sie gerade geübt haben.\n \n
				Die Aufgabe ist in mehrere Blöcke aufgeteilt.\n
				Nach jedem Block gibt es eine kleine Pause, deren Dauer Sie sich selbst einteilen können.\n \n \n
				Weiter mit einer beliebigen Taste.";
				}test_intro_text;
			x = 0;y = 0;};
			code="TEST_INTRO";
	};
}test_intro;

# intro text for test phase
trial{
	trial_type = first_response;
	trial_duration = forever;
	stimulus_event{
			picture{
			text{
				font = "Helvetica";
				font_size = 30;
				font_color = 0,0,0;
				background_color =214,213,213;
				caption = "<font size='40'><b>Testphase.</b></font>\n \n \n
				Wie zu Anfang angemerkt, können Sie bei einer guten Leistung in der Aufgabe \n
				zusätzliche Gewinne erzielen (z.B. Schokolade, Getränke, usw.) \n \n
				Zu Beginn eines jeden Blocks, verfärbt sich der Bildschirm entweder <font color='0,120,0'><b>GRÜN</b></font> oder <font color='84,84,84'><b>GRAU</b></font>. \n
				Ist der Bildschirm GRÜN, bedeutet das, dass Sie in dem folgenden Block \n
				für jede richtige Antwort Punkte bekommen. \n
				Dies wird Ihnen jedes Mal kurz rückgemeldet (<font color='0,120,0'><b>+1</b></font>). \n \n
				Weiter mit einer beliebigen Taste.";
				}manipulation_1_text;
			x = 0;y = 0;};
			code="MANIPULATION_1_INTRO";
	};
}manipulation_1_intro;



# intro text for test phase
trial{
	trial_type = first_response;
	trial_duration = forever;
	stimulus_event{
			picture{
			text{
				font = "Helvetica";
				font_size = 30;
				font_color =0,0,0;
				background_color =214,213,213;
				caption = "<font size='40'><b>Testphase.</b></font>\n \n \n
				Wie zu Anfang angemerkt, können Sie bei einer guten Leistung in der Aufgabe \n
				zusätzliche Gewinne erzielen (z.B. Schokolade, Getränke, usw.) \n \n
				Zu Beginn eines jeden Blocks, verfärbt sich der Bildschirm entweder <font color='0,120,0'><b>GRÜN</b></font> oder <font color='84,84,84'><b>GRAU</b></font>. \n
				Ist der Bildschirm GRÜN, bedeutet das, dass Sie in der folgenden Block gewertet wird. \n
				Sie bekommen am Ende der Sizung rückgemeldet, wie viele Punkte Sie gesammelt haben. \n \n
				Weiter mit einer beliebigen Taste.";
				}manipulation_0_text;
			x = 0;y = 0;};
			code="MANIPULATION_0_INTRO";
	};
}manipulation_0_intro;

# task instructions
array {
	LOOP $i 8;
	$k = '$i + 1';
	trial{
	trial_type = first_response;
	trial_duration = forever;
		picture{
		bitmap{
		system_memory = true;
		filename= "instruction_$k.PNG";
		width = 1920;                       # resize to 300x400
		height = 1080;};
		x = 0;y = 0;};
		code = "INSTRUCTION_$k";
		response_active = true;
	};
	ENDLOOP;
}instruction_trial;

# pause text
trial{
	trial_type = fixed;
	trial_duration = 30000;
	stimulus_event{
			picture{
			text{
				font = "Helvetica";
				font_size = 30;
				font_color = 0,0,0;
				background_color = 214,213,213;
				caption = "Es folgt eine kleine Pause. \n \n
				Du kannst dich etwas entspannen bevor es weiter geht.";
			}pause_text;
		x = 0; y = 0;};
		code="PAUSE";
	}pause_event;
}pause;

trial {
	trial_type = fixed;
	trial_duration = 10000;
	stimulus_event{
			picture{
		}manipulation_screen;
		code="MANUPULATION_SCREEN";
		port_code=99;
	   port = 1;
	}manipulation_event;
}manipulation;

# countdown
array{
	LOOP $i 3;
	$k = '$i + 1';
	trial{
	trial_duration = 1000;
		picture {
		text{
				font = "Helvetica";
				font_size = 50;
				font_color = 0,0,0;
				background_color =214,213,213;
				caption = "$k";
			};
		x = 0; y = 0;};
		code = "COUNTDOWN_$k";
	};
	ENDLOOP;
}countdown;

# end of task
trial{
	trial_type = first_response;
	trial_duration = forever;
	stimulus_event{
			picture{
			text{
				font = "Helvetica";
				font_size = 30;
				font_color = 255,255,255;
				background_color = 0,0,0;
				caption = "<font size='40'><b>Ende.</b></font>. \n \n \n \n
				Du hast es geschafft! Wir sind fertig für heute. \n \n
				Vielen Dank für Ihre Teilnahme. \n \n \n \n
				Bitte warte auf den Versuchsleiter";
			}the_end_text;
		x = 0;
		y = 0;
		};
		code="FINISHED";
	};
}the_end;

# mood ratings
array {
	LOOP $i 13;
	$k = '$i + 1';
	trial {
	trial_type = first_response;
	trial_duration = forever;
		picture {
		bitmap { system_memory = true; filename= "BFolie$k.PNG"; };
		x = 0; y = 0;};
		code = "MOOD_Rating_$k";
		response_active = true;
	};
	ENDLOOP;
} mood_rating;


############################################
##			 DPX-Task  Trial-Elemente			    ##
############################################

#################
### PICTURES ####
#################

### fix point

# picture { bitmap { system_memory = true; filename = "fix_point.PNG"; }; x = 0; y = 0;} fix_point;

picture { bitmap { system_memory = true; filename = "fix_point.PNG"; alpha = -1; }; x = 0; y = 0;} fix_point;

### CUES ###

picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Cue0.PNG"; alpha = -1;  };x = 0; y = 0;} Cue_A;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Cue1.PNG"; alpha = -1;  };x = 0; y = 0;} Cue_B_1;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Cue2.PNG"; alpha = -1;  };x = 0; y = 0;} Cue_B_2;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Cue3.PNG"; alpha = -1;  };x = 0; y = 0;} Cue_B_3;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Cue4.PNG"; alpha = -1;  };x = 0; y = 0;} Cue_B_4;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Cue5.PNG"; alpha = -1;  };x = 0; y = 0;} Cue_B_5;


### PROBES ####

picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Probe0.PNG"; alpha = -1;  };x = 0; y = 0;} Probe_X;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Probe1.PNG"; alpha = -1;  };x = 0; y = 0;} Probe_Y_1;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Probe2.PNG"; alpha = -1;  };x = 0; y = 0;} Probe_Y_2;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Probe3.PNG"; alpha = -1;  };x = 0; y = 0;} Probe_Y_3;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Probe4.PNG"; alpha = -1;  };x = 0; y = 0;} Probe_Y_4;
picture { background_color = 214, 213, 213; bitmap { system_memory = true; filename = "Probe5.PNG"; alpha = -1;  };x = 0; y = 0;} Probe_Y_5;


#######################################################
############    CUE-Trials    #########################
############						      #########################
############						      #########################

# inter-stimulus interval (ISI)
trial{
	trial_type = fixed;
	trial_duration = 500;
	stimulus_event {
		picture fix_point;
		time = 0;
		code = "ISI";
   }isi_event;
}isi_screen;


# inter-trial interval (ITI)
trial{
	trial_type = fixed;
	trial_duration = 1000;
	stimulus_event {
		picture fix_point;
		time = 0;
		code = "ITI";
   }iti_event;
}iti_screen;

trial {
	trial_duration = 400;
	trial_type = fixed;
	all_responses = false;
   stimulus_event {picture Cue_A;
		time = 0;
		duration = 400;
		code = "Cue_A";
		port_code = 70;
		port = 1;
		response_active = true;
   } Cue_event1;
} A_trial;

trial {
	trial_duration = 400;
	trial_type = fixed;
	all_responses = false;
   stimulus_event {picture Cue_B_1;
		time = 0;
		duration = 400;
		code = "Cue_B_1";
		port_code = 71;
		port = 1;
		response_active = true;
   } Cue_event2;
} B_trial_1;

trial {
	trial_duration = 400;
	trial_type = fixed;
	all_responses = false;
   stimulus_event {picture Cue_B_2;
		time = 0;
		duration = 400;
		code = "Cue_B_2";
		port_code = 72;
		port = 1;
		response_active = true;
   } Cue_event3;
} B_trial_2;

trial {
	trial_duration = 400;
	trial_type = fixed;
	all_responses = false;
   stimulus_event {picture Cue_B_3;
		time = 0;
		duration = 400;
		code = "Cue_B_3";
		port_code = 73;
		port = 1;
		response_active = true;
   } Cue_event4;
} B_trial_3;

trial {
	trial_duration = 400;
	trial_type = fixed;
	all_responses = false;
   stimulus_event {picture Cue_B_4;
		time = 0;
		duration = 400;
		code = "Cue_B_4";
		port_code = 74;
		port = 1;
		response_active = true;
   } Cue_event5;
} B_trial_4;

trial {
	trial_duration = 400;
	trial_type = fixed;
	all_responses = false;
   stimulus_event {picture Cue_B_5;
		time = 0;
		duration = 400;
		code = "Cue_B_5";
		port_code = 75;
		port = 1;
		response_active = true;
   } Cue_event6;
} B_trial_5;


#######################################################
############    PROBE-trials	#########################
############						      #########################
############						      #########################


trial {
	trial_duration = 750;
	trial_type = first_response;
   stimulus_event {picture Probe_X;
		time = 0;
		duration = 500;
		code = "Probe_X";
		port_code = 76;
		port = 1;
		response_active = true;
		target_button = 1;
   } Probe_event1;
} X_trial;

trial {
	trial_duration = 750;
	trial_type = first_response;
   stimulus_event {picture Probe_Y_1;
		time = 0;
		duration = 500;
		code = "Probe_Y_1";
		port_code = 77;
		port = 1;
		response_active = true;
		target_button = 1;
   } Probe_event2;
} Y_trial_1;

trial {
	trial_duration = 750;
	trial_type = first_response;
   stimulus_event {picture Probe_Y_2;
		time = 0;
		duration = 500;
		code = "Probe_Y_2";
		port_code = 78;
		port = 1;
		response_active = true;
		target_button = 1;
   } Probe_event3;
} Y_trial_2;

trial {
	trial_duration = 750;
	trial_type = first_response;
   stimulus_event {picture Probe_Y_3;
		time = 0;
		duration = 500;
		code = "Probe_Y_3";
		port_code = 79;
		port = 1;
		response_active = true;
		target_button = 1;
   } Probe_event4;
} Y_trial_3;

trial {
	trial_duration = 750;
	trial_type = first_response;
   stimulus_event {picture Probe_Y_4;
		time = 0;
		duration = 500;
		code = "Probe_Y_4";
		port_code = 80;
		port = 1;
		response_active = true;
		target_button = 1;
   } Probe_event5;
} Y_trial_4;

trial {
	trial_duration = 750;
	trial_type = first_response;
   stimulus_event {picture Probe_Y_5;
		time = 0;
		duration = 500;
		code = "Probe_Y_5";
		port_code = 81;
		port = 1;
		response_active = true;
		target_button = 13;
   } Probe_event6;
} Y_trial_5;


########
######## FEEDBACK #######
########
trial {
	trial_type = fixed;
	all_responses = false;
	trial_duration = 500;
	stimulus_event{
	   picture {
		   text {
				font="Calibri";
			   font_size = 36;
			   font_color = 0,255,0;
			   background_color= 214,213,213;
		      caption = "Richtig!";
		   } Correct;
		x = 0; y = 0;
	   } FB_picture_1;
	time = 0;
	code = "HIT_FB";
	port_code = 85;
	port = 1;
   } Feedback_event_1;
}FB_Correct;


trial {
	trial_type = fixed;
	all_responses = false;
  	trial_duration = 500;
	stimulus_event{
	   picture {
		   text {
				font="Calibri";
			   font_size = 36;
			   font_color =255,0,0;
			   background_color=214,213,213;
		      caption = "Falsch!";
		   }False;
		x = 0; y = 0;
	   } FB_picture_2;
	time=0;
	code = "ERROR_FB";
	port_code = 86;
	port = 1;
   } Feedback_event_2;
}FB_Falsch;

trial {
	trial_type = fixed;
	all_responses = false;
	trial_duration = 500;
	stimulus_event{
	   picture {
		   text {
				font="Calibri";
			   font_size = 36;
			    font_color = 255,185,15;
			   background_color= 214,213,213;
		      caption = "Zu langsam!";
		   }Slow;
			 x = 0; y = 0;
	   }FB_picture_3;
	time = 0;
	code = "SLOW_FB";
   } Feedback_event_3;
}FB_Slow;

trial{
	trial_type = fixed;
	all_responses = false;
	trial_duration = 2000;
	stimulus_event{
   picture {
		text {
			font="Calibri";
			font_size = 36;
			font_color =255,255,0;
			background_color= 214,213,213;
			caption = "Zu früh! \n Warten Sie auf die weiße Punkte";
		}Feedback_text;
			x = 0; y = 0;
   }FB_picture_4;
	 time = 0;
	 code = "EARLY_FB";
	 }Feedback_event_4;
}Feedback_trial;