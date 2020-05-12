namespace eval ::SQGUI:: {
    namespace export sqgui

    variable w;                     # handle to the base widget.
    variable version    "1.0";      # plugin version  

    variable vmd_Path   "";         # VMD environment path
    variable input_file_path  "";   # absolute path of the input molecule file 

    variable molid       "-1";      # molid of the molecule to grab
    variable moltxt        "";      # title the molecule to grab
    
    variable selection1    "all";   # selection string for first selection
    variable selection2    "all";   # selection string for second selection
    variable subselection1 "all";   # sub selection1 for statistics
    variable subselection2 "all";   # sub selection2 for statistics
    variable rbinRange     "all";   # R bins range for statistics
    variable atom_numbers_sel1 "";  # atom numbers in selection 1
    variable atom_numbers_sel2 "";  # atom numbers in selection 2
    variable useNonFFSq     1;      # Use non FF weighted S(q) for contributions

    variable delta      "0.1";      # delta for histogram
    variable rmax      "10.0";      # max r in histogram
    variable num_atoms      0;      # total number of atoms
    variable n_frames       0;      # total number of frames used

    variable first        "0";      # first frame
    variable last        "-1";      # last frame
    variable step         "1";      # frame step delta 

    variable useXRay      "1";      # Controls whether to use x-ray constants or neutron constants file for FF calculations 

    variable min_q        "0.5";    # min q value for partial s(q)s
    variable max_q        "2";      # max q value for partial s(q)s
    variable delta_q      "0.1";    # q step delta 

    variable density       0.0;     # total density
    variable density_normalized 0.0;# Normalized total density
    variable all_distances_count 0; #Sum of distance counts across all element pairs
    variable total_distances_count 0;#Sum of distance counts across all element pairs in the selections

    variable leftBin       "";      # bin represent left of peak of interest
    variable rightBin      "";      # bin represent right of peak of interest
    variable topN          "";      # Top N contributors of interest
    variable atomsAll      "";      # All atoms in selection

    variable displayAtoms "1";      # 1: display atoms, 0: display molecles
    variable addBeta      "1";      # 1: add betas by rank 0: add betas by contribution score
    
    variable cannotplot   "0";      # is multiplot available?
    variable enableStatistics 0;    # control varibale to decide whether the computer rankings button and corresponding controls should be enabled
    variable enableSelections 0;    # control varibale to decide whether the controls related to selections should be enabled
    variable enableRankings   0;    # control varibale to decide whether the rankings are calculated to enable visualization controls

    variable SQ_plot       "";      # Handler for S(Q) plot window
    variable x_SQ      "";          # S(q) plot X values
    variable y_SQ      "";          # S(q) plot Y values

    variable vis_selection1 "";             # Selection 1 for visualization
    variable selection1_colorId 0;          # colorID for selection 1
    variable selection1_color_method "";    # Coloring Method for selection 1
    variable selection1_material "";        # Material for selection 1
    variable selection1_draw_method "";     # Drawing Method for selection 1
    variable vis_selection2 "";             # Selection 2 for visualization
    variable selection2_colorId 0;          # colorID for selection 2
    variable selection2_color_method "";    # Coloring Method for selection 2
    variable selection2_material "";        # Material for selection 2
    variable selection2_draw_method "";     # Drawing Method for selection 2
    variable vis_selection3 "";             # Selection 3 for visualization
    variable selection3_colorId 0;          # colorID for selection 3
    variable selection3_color_method "";    # Coloring Method for selection 3
    variable selection3_material "";        # Material for selection 3
    variable selection3_draw_method "";     # Drawing Method for selection 3
    variable vis_selection4 "";             # Selection 4 for visualization
    variable selection4_colorId 0;          # colorID for selection 4
    variable selection4_color_method "";    # Coloring Method for selection 4
    variable selection4_material "";        # Material for selection 4
    variable selection4_draw_method "";     # Drawing Method for selection 4
    variable vis_selection5 "";             # Selection 5 for visualization
    variable selection5_colorId 0;          # colorID for selection 5
    variable selection5_color_method "";    # Coloring Method for selection 5
    variable selection5_material "";        # Material for selection 5
    variable selection5_draw_method "";     # Drawing Method for selection 5
    variable atom_beta_by_Score {};         # betas for atoms defined by score
    variable atom_beta_by_Rank_Sorted {};   # betas for atoms defined by rank
    variable atom_beta_by_Score_Sorted {};  # betas for atoms defined by score
    variable molecule_beta_by_Rank  {};     # betas for molecules defined by rank
    variable molecule_beta_by_Score {};     # betas for molecules defined by score

    variable atom_props "";
    variable auto_call      1;      # Controls if the all pairs selection is specifically made by user or not
    variable rank_plot  "";         # Plot handle for ranking atoms/neighbors

    set atoms_groupNames [dict create];                         # stores atoms number as key and element type are value in dictionary
    set groups_atomNos [dict create];                           # stores element type as key and atoms number are value in dictionary
    set group_formfactors [dict create];                        # stores the formfactors of all the element types
    set groupPair_formfactors [dict create];                    # stores the formfactors of all the possible element group pairs
    set subGroupPair_counts [dict create];                      # stores the counts of all the subgroup pairs
    set allPairsAggregated_counts [dict create];                # stores the aggregated counts of all the group pairs
    set allPairsAggregated_weights [dict create];               # stores the aggregated weights of all the group pairs
    set group_pair_s_q {};                                      # stores the partial S(q)s of all group pairs
    set ff_weighted_group_pair_s_q [dict create];               # stores the formfactor weighted partial S(q)s of all group pairs
    set rbin_contributions_for_total_S_q {};                    # stores r bin contributions for total S(q) at each q for selections
    set rbin_contributions_for_ff_weighted_S_q {};              # stores r bin contributions for form factored weighted S(q) at each q for selections
    set total_S_q_pos_contributions [dict create];              # stores +ve contributions of r bins at each q for total s(q)
    set total_S_q_neg_contributions [dict create];              # stores -ve contributions of r bins at each q for total s(q)
    set selection_S_q_pos_contributions [dict create];          # stores +ve contributions of r bins at each q for s(q) for selections
    set selection_S_q_neg_contributions [dict create];          # stores -ve contributions of r bins at each q for s(q) for selections
    set selection_weighted_S_q_pos_contributions [dict create]; # stores +ve contributions of r bins at each q for form factor weighted s(q) for selections
    set selection_weighted_S_q_neg_contributions [dict create]; # stores -ve contributions of r bins at each q for form factor weighted s(q) for selections
    
    set selection_atoms_counts [dict create];                   # Stores counts for each atom in the selection
    set all_atoms_counts [dict create];                         # Stores counts for each atom in the input file
    set possible_sq_contributions {};                           # Stores the S(q) values and positive and negative contributions to s(q) at each q for a count 1 at all possible bins.
    set possible_sq_contribution_differences {};                # Stores the difference in S(q)values and positive and negative contributions to s(q) at each q for a difference of 1 in count at all possible bins.
    set all_atom_contributions [dict create];                   # Stores for all atoms, each atom and its contribution to S(q), positive and negative components of S(q)
    set all_atom_contributions_ff [dict create];                # Stores for all atoms, each atom and its contribution to ff weighted S(q), positive and negative components of ff weighted S(q)
    set selection_atom_contributions [dict create];             # Stores for all atoms in the selection, each atom and its contribution to S(q), positive and negative components of S(q)

    set all_same_elements_weights {};               # store weights of all homogenous element pairs
    set all_same_group_pair_formfactors {};         # store form factors of all homogenous element pairs

    set selection_groups_weights_all_denominator [dict create]; # store weights of all element pairs with denominator as all-all distance counts

    set bin_totals {}
    set bin_matrix {}
    set atom_numbers {}
    set topN_Sorted {}
    set group_totals [dict create]
    set group_matrices [dict create]
    set group_bulk_stats [dict create]
    set group_pair_num_atoms [dict create]
    variable pi "3.1415926535897931";
}

package provide sqgui $SQGUI::version

#################
proc ::SQGUI::ladd {l} {::tcl::mathop::+ {*}$l}

# Ported to TCL using the original C++ code developed by Travis.
proc ::SQGUI::get_g_r {temp_y} {
    variable delta
    variable rmax
    variable density_normalized
    variable num_atoms
    variable n_frames

    set numbins [expr $rmax / $delta]   
    for {set q 0} {$q < $numbins} {incr q} {
        set cur_Y [lindex $temp_y $q]
        set lower_r [expr $q * $delta]
        set upper_r [expr $lower_r + $delta]
        set ideal_n [expr $density_normalized * [expr [expr $upper_r * $upper_r * $upper_r] - [expr $lower_r * $lower_r * $lower_r]]]
        set temp_gofr [expr double($cur_Y) / $num_atoms / $n_frames / $ideal_n]
        lappend y_gofr $temp_gofr
        lappend x_gofr $lower_r
    }
    
    return [list $x_gofr $y_gofr]
}

proc ::SQGUI::get_partial_g_r {bin_val_pairs pair_weight} {
    variable delta
    variable rmax
    variable density_normalized
    variable num_atoms
    variable n_frames

    set partial_density [expr $density_normalized * $pair_weight]
    set numbins [expr $rmax / $delta]   
    for {set q 0} {$q < $numbins} {incr q} {
        set cur_Y 0
        set lower_r [expr $q * $delta]
        if {$partial_density>0} then {
            if {[dict exists $bin_val_pairs $q]} then {
                set cur_Y [dict get $bin_val_pairs $q]
            } else {
                set cur_Y 0
            }
            
            set upper_r [expr $lower_r + $delta]
            set ideal_n [expr $partial_density * [expr [expr $upper_r * $upper_r * $upper_r] - [expr $lower_r * $lower_r * $lower_r]]]
            set temp_gofr [expr double($cur_Y) / $num_atoms / $n_frames / $ideal_n]
            lappend y_gofr $temp_gofr
        } else {
            lappend y_gofr 0
        }
        lappend x_gofr $lower_r
    }
    return [list $x_gofr $y_gofr]
}

proc ::SQGUI::get_s_q {y_gofr contributions_file_path} {
    global total_S_q_pos_contributions
    global total_S_q_neg_contributions

    set tcl_precision 12
    variable delta
    variable rmax
    variable pi
    variable min_q
    variable max_q
    variable delta_q
    variable density

    set numbins [expr $rmax / $delta]
    set maxIdx 0
    set got_Error 0
    set fp {}
    set pos_neg_lines {}

    set total_S_q_pos_contributions [dict create]
    set total_S_q_neg_contributions [dict create]
    set adjusted_max_q [expr $max_q + [expr $delta_q / 100]]

    ### add code write the rbin_contributions values to a file (for each q add all rbin_contributions)
    if {[string length $contributions_file_path]} {
        if {[catch {open $contributions_file_path a} fp]} then {
            set got_Error 1
            tk_dialog .errmsg {viewSq Error} "There was an error opening the file '$contributions_file_path'. Cannot write r contributions to file anymore." error 0 Dismiss
        }
    }

    # Loops over all qs and calculate S(q).
    for {set cur_q $min_q} {$cur_q <= $max_q} {set cur_q [expr {$cur_q + $delta_q}]} {
        set maxIdx $cur_q   
        set varx $cur_q
        set vary 0.0
        set rbin_contributions {} 
        set pos_contribution 0
        set neg_contribution 0
        
        # Loops over all rs and calculate S(q) for current q.
        for {set r 0} {$r < $numbins} {incr r} {
            set glist_item [lindex $y_gofr $r]
            set sin_expr [expr $varx * $r * $delta]         
            set sin_val [expr sin($sin_expr) ]
            set temp_expr [expr $glist_item - 1.0 ]
            set temp_vary1 [expr $r * $delta * $temp_expr] 
            set test_temp [expr $sin_val / $varx]
            set temp_vary2 [expr $temp_vary1 * $test_temp]
            set temp_vary2 [expr $temp_vary2 * 4 * $pi * $density * $delta]
            set vary [expr $vary + $temp_vary2]
            lappend rbin_contributions $temp_vary2
            
            # cummulative sum of positive and negative contributions to S(q) for current r.
            if {$temp_vary2>=0} {
                set pos_contribution [expr $pos_contribution + $temp_vary2]
            } else {
                set neg_contribution [expr $neg_contribution + $temp_vary2]
            }
        } 
        # Map that holds positive and negative contribution of S(q) at current q. 
        dict append total_S_q_pos_contributions $varx $pos_contribution 
        dict append total_S_q_neg_contributions $varx $neg_contribution 

        if {$got_Error==0} {
            set out_line $varx
            append out_line ","
            append out_line [join $rbin_contributions ","]
            append out_line ","
            append out_line $vary
            puts $fp $out_line

            set temp_line ""
            append temp_line $varx
            append temp_line ","
            append temp_line $pos_contribution
            append temp_line ","
            append temp_line $neg_contribution
            lappend pos_neg_lines $temp_line
        }

        lappend sqx $varx
        lappend sqy $vary
    }

    if {$got_Error==0} {
        puts $fp "*****"
        foreach {line} $pos_neg_lines {
            puts $fp $line
        }
        close $fp
    }

    return [list $sqx $sqy $maxIdx]
}

proc ::SQGUI::get_partial_s_q {y_gofr contributions_file_path element_pair pair_weight} {
    global selection_S_q_pos_contributions
    global selection_S_q_neg_contributions

    set tcl_precision 12
    variable delta
    variable rmax
    variable pi
    variable min_q
    variable max_q
    variable delta_q
    variable density

    set numbins [expr $rmax / $delta]
    set maxIdx 0
    set got_Error 0
    set fp {}
    set pos_neg_lines {}
    set rbin_contributions_to_S_q {}    
    set adjusted_max_q [expr $max_q + [expr $delta_q / 100]]

    ### add code write the rbin_contributions values to a file (for each ele-pair, for each q add all rbin_contributions)
    if {[string length $contributions_file_path]} {
        if {[catch {open $contributions_file_path a} fp]} then {
            set got_Error 1
            tk_dialog .errmsg {viewSq Error} "There was an error opening the file '$contributions_file_path'. Cannot write r contributions to file anymore." error 0 Dismiss
        } else {
            set pline $element_pair
            append plie ","
            append pline $pair_weight 
            puts $fp $pline
        }
    } else {
        set got_Error 1
    }

    for {set cur_q $min_q} {$cur_q <= $max_q} {set cur_q [expr {$cur_q + $delta_q}]} {
        set maxIdx $cur_q   
        set varx $cur_q
        set vary 0.0
        set rbin_contributions {}
        set pos_contribution 0
        set neg_contribution 0
        set rbin_contributions_for_q {}     

        for {set r 0} {$r < $numbins} {incr r} {
            set glist_item [lindex $y_gofr $r]
            set sin_expr [expr $varx * $r * $delta]         
            set sin_val [expr sin($sin_expr) ]
            set temp_expr [expr $glist_item - 1.0 ]
            set temp_vary1 [expr $r * $delta * $temp_expr] 
            set test_temp [expr $sin_val / $varx]
            set temp_vary2 [expr $temp_vary1 * $test_temp]
            set temp_vary2 [expr $temp_vary2 * 4 * $pi * $density * $delta]
            set temp_vary2 [expr $temp_vary2 * $pair_weight]
            set vary [expr $vary + $temp_vary2]
            lappend rbin_contributions $temp_vary2         
            if {$temp_vary2>=0} {
                set pos_contribution [expr $pos_contribution + $temp_vary2]
            } else {
                set neg_contribution [expr $neg_contribution + $temp_vary2]
            }
        }

        if {[dict exists $selection_S_q_pos_contributions $varx]==1} then {
            dict set selection_S_q_pos_contributions $varx [expr $pos_contribution + [dict get $selection_S_q_pos_contributions $varx]]
        } else {
            dict append selection_S_q_pos_contributions $varx $pos_contribution 
        }

        if {[dict exists $selection_S_q_neg_contributions $varx]==1} then {
            dict set selection_S_q_neg_contributions $varx [expr $neg_contribution + [dict get $selection_S_q_neg_contributions $varx]]
        } else {            
            dict append selection_S_q_neg_contributions $varx $neg_contribution
        }

        lappend rbin_contributions_to_S_q $rbin_contributions
        if {$got_Error==0} {
            set out_line $varx
            append out_line ","
            append out_line [join $rbin_contributions ","]
            append out_line ","
            append out_line $vary
            puts $fp $out_line

            set temp_line ""
            append temp_line $varx
            append temp_line ","
            append temp_line $pos_contribution
            append temp_line ","
            append temp_line $neg_contribution
            lappend pos_neg_lines $temp_line
        }

        lappend sqx $varx
        lappend sqy $vary
    }

    if {$got_Error==0} {
        puts $fp "*****"
        foreach {line} $pos_neg_lines {
            puts $fp $line
        }
        puts $fp "*****"
        close $fp
    }
    return [list $sqx $sqy $rbin_contributions_to_S_q]
}

proc ::SQGUI::get_partial_s_q_with_contributions {y_gofr pair_weight} {
    set s_q_pos_contributions {}
    set s_q_neg_contributions {}

    variable delta
    variable rmax
    variable pi
    variable min_q
    variable max_q
    variable delta_q
    variable density

    set rbin_contributions_to_S_q {}
    set numbins [expr $rmax / $delta]
    set adjusted_max_q [expr $max_q + [expr $delta_q / 100]]

    for {set cur_q $min_q} {$cur_q <= $max_q} {set cur_q [expr {$cur_q + $delta_q}]} {
        set varx $cur_q
        set vary 0.0
        set rbin_contributions {}
        set pos_contribution 0
        set neg_contribution 0

        for {set r 0} {$r < $numbins} {incr r} {
            set glist_item [lindex $y_gofr $r]
            set sin_expr [expr $varx * $r * $delta]         
            set sin_val [expr sin($sin_expr) ]
            set temp_expr [expr $glist_item - 1.0 ]
            set temp_vary1 [expr $r * $delta * $temp_expr] 
            set test_temp [expr $sin_val / $varx]
            set temp_vary2 [expr $temp_vary1 * $test_temp]
            set temp_vary2 [expr $temp_vary2 * 4 * $pi * $density * $delta]
            set temp_vary2 [expr $temp_vary2 * $pair_weight]
            set vary [expr $vary + $temp_vary2]
            lappend rbin_contributions $temp_vary2
            if {$temp_vary2>=0} {
                set pos_contribution [expr $pos_contribution + $temp_vary2]
            } else {
                set neg_contribution [expr $neg_contribution + $temp_vary2]
            }
        }

        lappend sqx $varx
        lappend sqy $vary
        lappend s_q_pos_contributions $pos_contribution 
        lappend s_q_neg_contributions $neg_contribution
        lappend rbin_contributions_to_S_q $rbin_contributions
    }

    return [list $sqx $sqy $s_q_pos_contributions $s_q_neg_contributions $rbin_contributions_to_S_q]
}

proc ::SQGUI::get_formfactor_weighted_partial_s_q {y_gofr weight pair_formfactor_list contributions_file_path element_pair } {
    global selection_weighted_S_q_pos_contributions
    global selection_weighted_S_q_neg_contributions
    global all_same_elements_weights
    global all_same_group_pair_formfactors

    set tcl_precision 12
    variable delta
    variable rmax
    variable pi
    variable min_q
    variable max_q
    variable delta_q
    variable density

    set numbins [expr $rmax / $delta]
    set maxIdx 0
    set got_Error 0
    set fp {}
    set pos_neg_lines {}
    set i_idx 0
    set rbin_contributions_to_ff_S_q {}
    set adjusted_max_q [expr $max_q + [expr $delta_q / 100]]

    ### add code write the rbin_contributions values to a file (for each ele-pair, for each q add all rbin_contributions)
    if {[string length $contributions_file_path]} {
        if {[catch {open $contributions_file_path a} fp]} then {
            set got_Error 1
            tk_dialog .errmsg {viewSq Error} "There was an error opening the file '$contributions_file_path'. Cannot write r contributions to file anymore." error 0 Dismiss
        } else {
            puts $fp $element_pair
        }
    } else {
        set got_Error 1
    }

    for {set cur_q $min_q} {$cur_q <= $max_q} {set cur_q [expr {$cur_q + $delta_q}]} {
        set maxIdx $cur_q   
        set varx $cur_q
        set vary 0.0
        set rbin_contributions {} 
        set pos_contribution 0
        set neg_contribution 0
        set formfactor [lindex $pair_formfactor_list $i_idx]
        set denominator_at_q 0
        # calculate the denoinator as weighted sum of formfactors for homogenous element pairs.
        for {set k 0} {$k < [llength $all_same_elements_weights]} {incr k} {
            set pair_weight [lindex $all_same_elements_weights $k]
            set pair_formfactor [lindex $all_same_group_pair_formfactors $k]
            set element_weight [expr { sqrt($pair_weight) }]
            set pair_formfactor_at_q [lindex $pair_formfactor $i_idx]
            set element_formfactor_at_q [expr { sqrt($pair_formfactor_at_q) }]
            set denominator_at_q [expr $denominator_at_q + [expr $element_weight * $element_formfactor_at_q]]
        }

        set denominator_at_q [expr $denominator_at_q * $denominator_at_q]

        # At each q, calculate S(q) as running sum of product of r calcuation, pair weight, formfactor and divide by the calculated denominator.
        for {set r 0} {$r < $numbins} {incr r} {
            set glist_item [lindex $y_gofr $r]
            set sin_expr [expr $varx * $r * $delta]         
            set sin_val [expr sin($sin_expr) ]
            set temp_expr [expr $glist_item - 1.0 ]
            set temp_vary1 [expr $r * $delta * $temp_expr] 
            set test_temp [expr $sin_val / $varx]
            set temp_vary2 [expr $temp_vary1 * $test_temp]
            set temp_vary2 [expr $temp_vary2 * 4 * $pi * $density * $delta]
            set temp_vary2 [expr $temp_vary2 * $weight]
            set temp_vary2 [expr $temp_vary2 * $formfactor]
            set temp_vary2 [expr $temp_vary2 / $denominator_at_q]
            set vary [expr $vary + $temp_vary2]
            lappend rbin_contributions $temp_vary2
            if {$temp_vary2>=0} {
            set pos_contribution [expr $pos_contribution + $temp_vary2]
            } else {
            set neg_contribution [expr $neg_contribution + $temp_vary2]
            }
        }

        # Also keep track of positive and negative contributions to form factored weighted S(q).
        if {[dict exists $selection_weighted_S_q_pos_contributions $varx]==1} then {
            dict set selection_weighted_S_q_pos_contributions $varx [expr $pos_contribution + [dict get $selection_weighted_S_q_pos_contributions $varx]]
        } else {
            dict append selection_weighted_S_q_pos_contributions $varx $pos_contribution 
        }

        if {[dict exists $selection_weighted_S_q_neg_contributions $varx]==1} then {
            dict set selection_weighted_S_q_neg_contributions $varx [expr $neg_contribution + [dict get $selection_weighted_S_q_neg_contributions $varx]]
        } else {            
            dict append selection_weighted_S_q_neg_contributions $varx $neg_contribution
        }

        lappend rbin_contributions_to_ff_S_q $rbin_contributions
        if {$got_Error==0} {
            set out_line $varx
            append out_line ","
            append out_line [join $rbin_contributions ","]
            append out_line ","
            append out_line $vary
            puts $fp $out_line

            set temp_line ""
            append temp_line $varx
            append temp_line ","
            append temp_line $pos_contribution
            append temp_line ","
            append temp_line $neg_contribution
            append temp_line ","
            append temp_line $vary
            lappend pos_neg_lines $temp_line
        }

        lappend sqx $varx
        lappend sqy $vary
        incr i_idx
    }

    if {$got_Error==0} {
        puts $fp "*****"
        foreach {line} $pos_neg_lines {
            puts $fp $line
        }
        close $fp
    }
    return [list $sqx $sqy $rbin_contributions_to_ff_S_q]
}

proc ::SQGUI::get_formfactor_weighted_partial_s_q_with_contributions {y_gofr weight pair_formfactor_list } {
    global all_same_elements_weights
    global all_same_group_pair_formfactors
    set s_q_pos_contributions {}
    set s_q_neg_contributions {}

    set tcl_precision 12
    variable delta
    variable rmax
    variable pi
    variable min_q
    variable max_q
    variable delta_q
    variable density

    set numbins [expr $rmax / $delta]
    set maxIdx 0
    set got_Error 0
    set fp {}
    set pos_neg_lines {}
    set i_idx 0
    set rbin_contributions_to_ff_S_q {}
    set adjusted_max_q [expr $max_q + [expr $delta_q / 100]]

    for {set cur_q $min_q} {$cur_q <= $max_q} {set cur_q [expr {$cur_q + $delta_q}]} {
        set maxIdx $cur_q   
        set varx $cur_q
        set vary 0.0
        set rbin_contributions {} 
        set pos_contribution 0
        set neg_contribution 0
        set formfactor [lindex $pair_formfactor_list $i_idx]
        set denominator_at_q 0
        # calculate the denoinator as weighted sum of formfactors for homogenous element pairs.
        for {set k 0} {$k < [llength $all_same_elements_weights]} {incr k} {
            set pair_weight [lindex $all_same_elements_weights $k]
            set pair_formfactor [lindex $all_same_group_pair_formfactors $k]
            set element_weight [expr { sqrt($pair_weight) }]
            set pair_formfactor_at_q [lindex $pair_formfactor $i_idx]
            set element_formfactor_at_q [expr { sqrt($pair_formfactor_at_q) }]
            set denominator_at_q [expr $denominator_at_q + [expr $element_weight * $element_formfactor_at_q]]
        }

        set denominator_at_q [expr $denominator_at_q * $denominator_at_q]

        # At each q, calculate S(q) as running sum of product of r calcuation, pair weight, formfactor and divide by the calculated denominator.
        for {set r 0} {$r < $numbins} {incr r} {
            set glist_item [lindex $y_gofr $r]
            set sin_expr [expr $varx * $r * $delta]         
            set sin_val [expr sin($sin_expr) ]
            set temp_expr [expr $glist_item - 1.0 ]
            set temp_vary1 [expr $r * $delta * $temp_expr] 
            set test_temp [expr $sin_val / $varx]
            set temp_vary2 [expr $temp_vary1 * $test_temp]
            set temp_vary2 [expr $temp_vary2 * 4 * $pi * $density * $delta]
            set temp_vary2 [expr $temp_vary2 * $weight]
            set temp_vary2 [expr $temp_vary2 * $formfactor]
            set temp_vary2 [expr $temp_vary2 / $denominator_at_q]
            set vary [expr $vary + $temp_vary2]
            lappend rbin_contributions $temp_vary2
            if {$temp_vary2>=0} {
            set pos_contribution [expr $pos_contribution + $temp_vary2]
            } else {
            set neg_contribution [expr $neg_contribution + $temp_vary2]
            }
        }
    
        lappend s_q_pos_contributions $pos_contribution 
        lappend s_q_neg_contributions $neg_contribution
        lappend sqy $vary
        incr i_idx
    }

    return [list $sqy $s_q_pos_contributions $s_q_neg_contributions]
}

proc ::SQGUI::convertListToDict {valuesList} {
    variable delta
    variable rmax
    
    set pairsDict [dict create]
    set numbins [expr $rmax / $delta]
    
    for {set r 0} {$r < $numbins} {incr r} {
        if {[lindex $valuesList $r] >0} {
            dict append pairsDict $r [lindex $valuesList $r]
        }
    }
    return $pairsDict
}

proc ::SQGUI::runSofQ {} {
    global bin_totals
    global bin_matrix
    global atom_numbers
    global subGroupPair_counts
    global total_S_q_pos_contributions
    global total_S_q_neg_contributions
    global allPairsAggregated_counts
    global allPairsAggregated_weights
    global all_same_elements_weights
    global all_same_group_pair_formfactors

    global group_totals
    global group_matrices
    global group_bulk_stats
    global group_pair_num_atoms
    
    variable pi
    variable enableSelections
    variable w
    variable molid
    variable selection1
    variable selection2
    variable delta
    variable rmax
    variable first
    variable last
    variable step
    variable min_q
    variable max_q
    variable delta_q
    variable cannotplot
    variable SQ_plot
    variable x_SQ
    variable y_SQ
    variable input_file_path
    variable vmd_Path
    variable num_atoms
    variable n_frames
    variable density
    variable density_normalized
    variable total_distances_count
    variable all_distances_count
    variable auto_call

    set vmd_Path $::env(VMDDIR)
    set errmsg {}
    set cannotplot [catch {package require multiplot 1.1}]
    set tcl_precision 12
    set sel {}

    if {[catch {atomselect $molid "all"} sel]} then {
        tk_dialog .errmsg {viewSq Error} "There was an error creating the selection: all" error 0 Dismiss
        return
    }

    if {$last==-1} then {
        set last [molinfo $molid get numframes]
    } 

    puts "Calculating total g(r)..."
    set test_infile [molinfo 0 get filename]                                                                        
    set last_delim [string last "/" $test_infile ]
    set first_delim [string first "/" $test_infile ]
    set folder_path [string range $test_infile $first_delim $last_delim]
    set input_file_path $folder_path    
    append folder_path "Selected_Frames_Coordinates.dat"
    set is_first_frame 1
    set is_last_frame 0
    for {set frm $first} {$frm <= $last} {incr frm $step} {
        if {$frm == $last || [expr $frm + $step]>$last} {
            set is_last_frame 1
        }
        set outfile $folder_path
        set fp {}
        if {[string length $outfile]} {
            if {[catch {open $outfile w} fp]} then {
                tk_dialog .errmsg {viewSq Error} "There was an error opening the output file '$outfile':\n\n$fp" error 0 Dismiss
            } else {    
                set newsel [atomselect $molid "all" frame $frm]
                set num_atoms_sel_1 [$newsel num]
                set num_atoms_sel_2 $num_atoms_sel_1
                set sel_result_coords_x [$newsel get x]
                set sel_result_coords_y [$newsel get y]
                set sel_result_coords_z [$newsel get z]
                set sel_result_atom_numbers [$newsel get serial]
                set sel_result_residue_id [$newsel get resid]
                set sel_result_type [$newsel get type]

                for {set idx 0} {$idx < $num_atoms_sel_1} {incr idx} {
                    set coords_x [lindex $sel_result_coords_x $idx]
                    set coords_y [lindex $sel_result_coords_y $idx]
                    set coords_z [lindex $sel_result_coords_z $idx]
                    set cur_id [lindex $sel_result_atom_numbers $idx]
                    set cur_type [lindex $sel_result_residue_id $idx]
                    set cur_resid [lindex $sel_result_type $idx]
                    puts $fp "$cur_id, $cur_type, $cur_resid, $coords_x, $coords_y, $coords_z"
                }
                close $fp

                set ::SQGUI::pybin [::ExecTool::find -interactive -description "Python executable" python]
                set scriptpath $vmd_Path
                append scriptpath "/scripts/python/Calculate_rdf_stats_py.py"
                set ::SQGUI::testscript $scriptpath
                # Comment the below line to not call python script and re-use the existing output from the python.
                # Command line call to run python script Calculate_rdf_stats_py.py
                set status [exec $::SQGUI::pybin $::SQGUI::testscript $folder_path $delta $rmax $is_first_frame $is_last_frame]
                set is_first_frame 0
                incr n_frames 
            }
            puts "Frame $frm Done!"
        }
    }  

    # File that contains histogram counts across all frames.
    set filename $input_file_path
    append filename "GofRValues.txt"

    set f [open $filename r]
    set data [split [read $f] "\n"]
    close $f

    set numbins [expr $rmax / $delta]

    # Read only the lines corresponding to histogram counts.
    foreach {line} $data {
        set firstWord [string range $line 0 2]
        if {$firstWord=="BOX"} {        
            set line_split [split $line ":"]            
            set length_vals [lindex $line_split 1]
            set running_box_lengths [split $length_vals ","]
            break               
        }
        lappend y_gofr_temp $line
    }

    set all_distances_count [ladd $y_gofr_temp]
    set total_distances_count $all_distances_count
    set num_atoms $num_atoms_sel_1
    set density [expr $num_atoms_sel_2 / [expr [expr [lindex $running_box_lengths 0] / $n_frames] * [expr [lindex $running_box_lengths 1] / $n_frames] * [expr [lindex $running_box_lengths 2] / $n_frames]]]
    set density_normalized [expr [expr 4 * $pi * $density] / 3]

    set gofr_result [get_g_r $y_gofr_temp]

    # get_g_r method return a list of lists where index 
    #       0- list of x values
    #       1- list of y values
    set x_gofr [lindex $gofr_result 0]
    set y_gofr [lindex $gofr_result 1]

    # show the plot of g(r) calculation.
    if {$cannotplot} then {
        tk_dialog .errmsg {viewSq Error} "Multiplot is not available." error 0 Dismiss
    } else {
        set gofr_plot [multiplot -x $x_gofr -y $y_gofr -title "g(r) plot (total atomic distances: $total_distances_count, all-all)" -lines -linewidth 2 -marker point -plot ]
    }

    set total_S_q_contributions_file $input_file_path
    append total_S_q_contributions_file "r_contributions_total_sq.dat"
    file delete $total_S_q_contributions_file

    set qmax [expr 1.0 / $delta]     
    set dq [expr $qmax / $numbins]  
    puts "Calculating total S(q)..."
    set sofq_result [get_s_q $y_gofr $total_S_q_contributions_file]
     # get_s_q method return a list of lists where index 
    #       0- list of qs in S(q)
    #       1- list of S(q) values
    set sqx [lindex $sofq_result 0]
    set sqy [lindex $sofq_result 1]
    set maxIdx [lindex $sofq_result 2]

    # show the plot of S(q), positive and negative components of S(q), sum of absolute components of S(q).
    if {$cannotplot} then {
        tk_dialog .errmsg {viewSq Error} "Multiplot is not available." error 0 Dismiss
    } else {
        set tmp 4
        # Total S(q) plot
        set SQ_plot [multiplot -x $sqx -y $sqy -title "S(q) plot (all-all)" -lines -linewidth 2 -marker point -legend "S(q)" -plot ]
        set total_S_q_pos_contributions_y [dict values $total_S_q_pos_contributions]
        set total_S_q_neg_contributions_y [dict values $total_S_q_neg_contributions]

        # Positive and negative components of S(q) plot
        set SQ_plot_pos_neg_contributions [multiplot -x $sqx -y $total_S_q_pos_contributions_y -title "Positive and negative contributions for total S(q) plot (all-all)" \
                                                -lines -linewidth 2 -marker point -linecolor green -fillcolor black -legend "Positive Contribution"]
        $SQ_plot_pos_neg_contributions add $sqx $total_S_q_neg_contributions_y -lines -linewidth 2 -marker point -linecolor red -fillcolor black -legend "Negative Contribution" -plot

        set S_q_pos_abs_neg_contributions $total_S_q_pos_contributions_y
        set k_idx 0
        foreach neg_value $total_S_q_neg_contributions_y {
            lset S_q_pos_abs_neg_contributions $k_idx [expr abs($neg_value) + [lindex $S_q_pos_abs_neg_contributions $k_idx] ]
            incr k_idx
        }

        # Sum of absolute components of S(q) plot.
        set SQ_plot_pos_abs_neg_contributions [multiplot -x $sqx -y $S_q_pos_abs_neg_contributions -title "Sum of positive and magnitude of negative contributions for total S(q) plot (all-all)" -lines -linewidth 2 -marker point -plot ]
    }

    # Disable the Compute S(q) button to stop calling runSofQ() again!
    $w.foot configure -state disabled

    # Read the elements.ndx file and keep the contents in a dictionary.
    set readStatus [readElementsFile]
    if {$readStatus!=0} then {
        return
    }

    set x_SQ $sqx
    set y_SQ $sqy
    set startNewRead 0
    set startedReadingGroups 0
    set readTotals 0
    set numbins [expr $rmax / $delta]
    set separator ","
    set cnt 0
    set cur_groupPair ""
    set rows {}

    set total_bins_done 0
    set total_bins_started 0

    foreach {line} $data {
        if {$line == ""} {
            continue
        }
        set firstChar [string range $line 0 0]
        
        if {$startedReadingGroups == 1} then {
        ### Read the current line,
        ###     if it starts with '[' read the line as group pair's key
        ###     if not, read the line as group pair's (bin:value) pairs and process them.
            if {$firstChar == "\["} then {
                set cur_groupPair  $line
            } else {
                # Split the line by comma to get pairs of the form (bin_num, bin_value)
                set cur_group_counts [dict create]
                set bins_values [split $line $separator]
                if {[llength $bins_values] > 0} then {
                    foreach {bin_val} $bins_values {
                        set bin_val_pair [split $bin_val ":"]
                        dict append cur_group_counts [lindex $bin_val_pair 0] [lindex $bin_val_pair 1]
                    }
                } else {
                    set bin_val_pair [split $line ":"]
                    dict append cur_group_counts [lindex $bin_val_pair 0] [lindex $bin_val_pair 1]
                }
                dict append subGroupPair_counts $cur_groupPair $cur_group_counts
            }

        } elseif {$line == "*****" && $total_bins_started==0} then {
        ### First time the delimeter '*****' occurs. It means next few lines are atom bin counts .
            set total_bins_started 1
            continue
        } elseif {$line == "*****" && $total_bins_started==1} then {
        ### Second time the delimeter '*****' occurs. It means atom bin counts are done and next few lines are group pairs.
            set $total_bins_done 1
            set total_bins_started 0
            set startedReadingGroups 1
        } elseif {$firstChar == "T"} then {
        ### Read the current line as Totals, which means, all the lines read into collection "rows" so far are bin counts for each atom.
            set readTotals 1
            set bin_matrix $rows 
            set rows {}
        } elseif {$readTotals == 1} then {
        ### Read 1 line that has column totals for the first matrix - bin counts measured with out using group pairs.
            set bin_totals [split $line $separator]
            set readTotals 0
        } elseif {$total_bins_started==1} then {
        ### Read the first matrix - bin counts measured with out using group pairs.
            set cur_binlist [split $line $separator]
            lappend atom_numbers [lindex $cur_binlist 0]
            lappend rows [lrange $cur_binlist 1 end]
        }
    }
    set total_distances_count [ladd $bin_totals]

    puts "Calculating total form factor weighted S(q)..."    
    ProcessAllsubGroupPairs

    set auto_call 0
    computePartialsForSelections $allPairsAggregated_counts $allPairsAggregated_weights
    puts "Completed!"

    set enableSelections 1
    EnDisable
    $w.foot configure -state disabled
}

# proc ::SQGUI::testBinSummands {total_dist} {
#     global bin_totals
#     puts "total: $total_dist"

#     for {set i 0} {$i < [llength $bin_totals]} {incr i} {
#         set weight [expr double([lindex $bin_totals $i])/$total_dist]
#         set counts_bin [dict create]
#         dict append counts_bin $i [lindex $bin_totals $i]
#         set partial_gofr [get_partial_g_r $counts_bin $weight]
#         set y_partial_gofr [lindex $partial_gofr 1]
#         set partial_sofq [get_partial_s_q $y_partial_gofr "" "" $weight]  
#         set y_partial_sofq [lindex $partial_sofq 1] 
        
#         puts "$counts_bin >>> $weight >>> $y_partial_sofq"
#     }
# }

proc ::SQGUI::readElementsFile {} {
    global atoms_groupNames
    global groups_atomNos
    global group_formfactors
    global groupPair_formfactors

    variable vmd_Path
    variable input_file_path
    variable min_q
    variable max_q
    variable delta_q
    variable pi
    variable useXRay

    set fp {}

    set formfactorsfilepath $vmd_Path
    if {$useXRay==1} then {
        append formfactorsfilepath "/plugins/noarch/tcl/viewsq1.0/form_factors_xray.csv"    
    } else {
        append formfactorsfilepath "/plugins/noarch/tcl/viewsq1.0/form_factors_neutron.csv"
    }
    
    # 1. Reading atomic form factors file
    set form_factor_constants [dict create]
    if {[catch {open $formfactorsfilepath r} fp]} then {
        tk_dialog .errmsg {viewSq Error} "There was an error opening the file '$formfactorsfilepath':\n\n$fp" error 0 Dismiss
    } else {
        set lines [split [read $fp] "\n"]
        close $fp
        set line_count [expr [llength $lines] - 1]
        set header [lindex $lines 0]
        set header_split [split $header ","]
        for {set idx 1} {$idx < $line_count} {incr idx} {
            set factors {}
            set cur_line [lindex $lines $idx]
            set line_split [split $cur_line ","]
            for {set j_idx 1} {$j_idx < [llength $line_split]} {incr j_idx} {
                if {[lindex $line_split $j_idx] != ""} {
                    lappend factors [lindex $line_split $j_idx] 
                }
            }
            set element [lindex $line_split 0]
            append dict_key "\[" $element "\]"
            if {[llength $factors]>0} {
                dict lappend form_factor_constants $dict_key $factors
            }
            
            set dict_key ""
        }
    }
    
    # 2. Reading elements.ndx file and calculating Gaussian sums for each element for each q in the specified q range
    set elements_file_path $input_file_path
    append elements_file_path "elements.ndx"
    if {[catch {open $elements_file_path r} fp]} then {
        tk_dialog .errmsg {viewSq Error} "There was an error opening the file '$elements_file_path':\n\n$fp" error 0 Dismiss
    } else {
        set lines [split [read $fp] "\n"]
        close $fp
        set line_count [expr [llength $lines]]
        set cur_group ""
        for {set idx 0} {$idx < $line_count} {incr idx} {
            set cur_line [lindex $lines $idx]
            set cur_line_length [string length $cur_line]
            if {$cur_line_length > 0} then {
                # if current line starts with "[" read the line as element name
                # else read the line split it by " " to get the list of atoms of previously read element type.
                if {[string range $cur_line 0 0] == "\["} then {
                    set cur_group $cur_line
                } elseif {[string range $cur_line 0 0] != "\["} then {
                    # It is possible to to have duplicate elements. search for delimeter ":" to see if the current element is a duplicate of some other element
                    set valid_grp $cur_group
                    set cur_group_split [split $cur_group ":"]
                    set cur_group_split_len [llength $cur_group_split]
                    if {$cur_group_split_len > 1} then {
                        set valid_grp [lindex $cur_group_split 0]
                        append valid_grp "\]"
                    }
                    set cur_group_atoms [split $cur_line " "]
                    dict lappend groups_atomNos $cur_group $cur_group_atoms
                    foreach atomNo $cur_group_atoms {
                        dict append atoms_groupNames $atomNo $cur_group
                    }

                    # if using x-ray file, fetch the constants of the correpsonding element and calculate atomic form factor
                    if {$useXRay==1} then {
                        set constants [split [lindex [dict get $form_factor_constants $valid_grp] 0] " "]
                        set formfactor {}
                        for {set cur_q $min_q} {$cur_q <= $max_q} {set cur_q [expr {$cur_q + $delta_q}]} {
                            set const_term [expr 4 * $pi]
                            set temp_q [expr $cur_q / $const_term]
                            set temp_q [expr pow($temp_q, 2)]
                            set temp [lindex $constants 0]
                            set temp [lindex $constants 1]

                            # Calculate a1*e(-b1*square(q/4pi))
                            set b_term [expr [lindex $constants 1] * $temp_q]
                            set exp_b_term [expr exp([expr -$b_term])]
                            set f_q [expr [lindex $constants 0] * $exp_b_term]

                            # Calculate a2*e(-b2*square(q/4pi)) and add the result to previous result
                            set b_term [expr [lindex $constants 3] * $temp_q]
                            set exp_b_term [expr exp([expr -$b_term])]
                            set f_q [expr $f_q + [expr [lindex $constants 2] * $exp_b_term]]

                            # Calculate a3*e(-b3*square(q/4pi)) and add the result to previous result
                            set b_term [expr [lindex $constants 5] * $temp_q]
                            set exp_b_term [expr exp([expr -$b_term])]
                            set f_q [expr $f_q + [expr [lindex $constants 4] * $exp_b_term]]

                            # Calculate a4*e(-b4*square(q/4pi)) and add the result to previous result
                            set b_term [expr [lindex $constants 7] * $temp_q]
                            set exp_b_term [expr exp([expr -$b_term])]
                            set f_q [expr $f_q + [expr [lindex $constants 6] * $exp_b_term]]

                            # Finally add c to the previous result
                            set f_q [expr $f_q + [lindex $constants 8]]

                            lappend formfactor $f_q
                        }
                    } else {
                        # if using neutron file, fetch the constant of the correpsonding element and use it as atomic form factor
                        if {$valid_grp in [dict keys $form_factor_constants]} then {
                            set f_q [dict get $form_factor_constants $valid_grp]
                        } else {
                            tk_dialog .errmsg {viewSq Error} "There is an element type defined in '$elements_file_path' without a valid formfactor constant in $formfactorsfilepath" error 0 Dismiss
                            return -1
                        }
                        
                        set formfactor {}
                        for {set cur_q $min_q} {$cur_q <= $max_q} {set cur_q [expr {$cur_q + $delta_q}]} {
                            lappend formfactor $f_q
                        }
                    }
                    dict lappend group_formfactors $cur_group $formfactor
                }
            }
        }

        # 3. Create a list of all possible element pairs
        set elements [dict keys $group_formfactors]
        set ele_pairs {}
        for {set i_idx 0} {$i_idx < [llength $elements]} {incr i_idx} {
            append pair [lindex $elements $i_idx] " " [lindex $elements $i_idx]
            lappend ele_pairs $pair
            for {set j_idx [expr $i_idx + 1]} {$j_idx < [llength $elements]} {incr j_idx} {
                append crosspair [lindex $elements $i_idx] " " [lindex $elements $j_idx]
                lappend ele_pairs $crosspair
                set crosspair ""
            }
            set pair ""
        }

        # 4. Calculating form factors for all the possible element pairs for each q in the specified range
        foreach {ele_pair} $ele_pairs {
            set eles_in_pair [split $ele_pair " "]
            set ele_pair_reverse "[lindex $eles_in_pair 1] [lindex $eles_in_pair 0]"
            set ele1_formfactors [split [lindex [dict get $group_formfactors [lindex $eles_in_pair 0]] 0] " "]
            set ele2_formfactors [split [lindex [dict get $group_formfactors [lindex $eles_in_pair 1]] 0] " "]
            set pair_formfactor {}
            for {set idx 0} {$idx < [llength $ele1_formfactors]} {incr idx} {
                lappend pair_formfactor [expr [lindex $ele1_formfactors $idx] * [lindex $ele2_formfactors $idx]]
            }
            dict lappend groupPair_formfactors $ele_pair $pair_formfactor
            dict lappend groupPair_formfactors $ele_pair_reverse $pair_formfactor
        }
    }
    return 0
}

proc ::SQGUI::ProcessAllsubGroupPairs {} {
    global atoms_groupNames
    global bin_totals
    global subGroupPair_counts
    global allPairsAggregated_counts
    global allPairsAggregated_weights
    global all_same_elements_weights
    global all_same_group_pair_formfactors
    global groupPair_formfactors 
    global all_atoms_counts
    global possible_sq_contributions
    global all_atom_contributions
    global all_atom_contributions_ff
    global possible_sq_contribution_differences
    global selection_groups_weights_all_denominator

    set allPairsAggregated_counts [dict create]
    set allPairsAggregated_weights [dict create]
    set all_same_elements_weights {}
    set all_same_group_pair_formfactors {}
    set all_atoms_counts [dict create]
    set all_atoms_counts_by_group [dict create]
    set all_atom_contributions [dict create]
    set all_atom_contributions_ff [dict create] 
    set selection_groups_weights_all_denominator [dict create]
    set unit_sofqs [dict create]
    set unit_sofqs_ff [dict create]
    set write_to_file 0    
    set fp {}    
    set fp1 {}   

    variable all_distances_count
    variable auto_call
    variable input_file_path

    set neighbour_contributions_file $input_file_path
    set neighbour_ff_contributions_file $input_file_path
    set write_to_file 0

    # Create a file that stores S(q) contributions of an atom from each of the neighbours.
    # Format:
    #   Each line represents contributions from all neighbours with one atom.
    #   Atom_number {neighbour_atom_number_1 {List of S(q) contributions} neighbour_atom_number_2 {List of S(q) contributions} neighbour_atom_number_3 {List of S(q) contributions}...}
    append neighbour_contributions_file "neighbour_contributions_sq.dat"
    if {[catch {open $neighbour_contributions_file w} fp]} then {
        set got_Error 1
        tk_dialog .errmsg {viewSq Error} "There was an error opening the file '$neighbour_contributions_file'" error 0 Dismiss
    } else {
        set write_to_file 1     
    }

    append neighbour_ff_contributions_file "neighbour_contributions_ff_sq.dat"
    if {[catch {open $neighbour_ff_contributions_file w} fp1]} then {
        set got_Error 1
        set write_to_file 0
        tk_dialog .errmsg {viewSq Error} "There was an error opening the file '$neighbour_ff_contributions_file'" error 0 Dismiss
    } else {
        set write_to_file 1     
    }    
    
    # aggregate the individual atom pair counts in such a way that we have dictionary with 
    #   key: atom number
    #   value: list of all counts the atom has with different neighbours [[neighbour1 bin:count] [neighbour2 bin:count] [neighbour3 bin:count]...]
    foreach subgrp_pair [dict keys $subGroupPair_counts] {

        set subGroups [split $subgrp_pair " "]
        set subGroup1_parts [split [lindex $subGroups 0] ":"]
        set subGroup2_parts [split [lindex $subGroups 1] ":"]
        set group1_name ""
        set group2_name ""
        set atom_i ""
        set atom_j ""
        if {[llength $subGroup1_parts]==2} then {
            set group1_name "[lindex $subGroup1_parts 0]\]"         
            set atom_i [lindex $subGroup1_parts 1] 
        } else {            
            set group1_name "[lindex $subGroup1_parts 0]:[lindex $subGroup1_parts 1]\]"
            set atom_i [lindex $subGroup1_parts [expr [llength $subGroup1_parts]-1]]
        }
        if {[llength $subGroup2_parts]==2} then {
            set group2_name "[lindex $subGroup2_parts 0]\]"
            set atom_j [lindex $subGroup2_parts 1]
        } else {
            set group2_name "[lindex $subGroup2_parts 0]:[lindex $subGroup2_parts 1]\]"
            set atom_j [lindex $subGroup2_parts [expr [llength $subGroup2_parts]-1]]
        }

        set atom_i [string range $atom_i 0 end-1]
        set atom_j [string range $atom_j 0 end-1]

        set grp_pair "$group1_name $group2_name"
        set grp_pair_reverse "$group2_name $group1_name"
        set counts [dict get $subGroupPair_counts $subgrp_pair]
        
        if { [dict exists $allPairsAggregated_counts $grp_pair] ==1 } then {
            dict lappend allPairsAggregated_counts $grp_pair $counts    
        } elseif { [dict exists $allPairsAggregated_counts $grp_pair_reverse] ==1 } then {  
            dict lappend allPairsAggregated_counts $grp_pair_reverse $counts
        } else {
            dict lappend allPairsAggregated_counts $grp_pair $counts                
        }

        dict lappend all_atoms_counts $atom_i [list $atom_j $counts]
        dict lappend all_atoms_counts $atom_j [list $atom_i $counts]  
        # dict lappend all_atoms_counts_by_group  
    }

    # aggregate the individual atom pair counts in such a way that we have dictionary with 
    #   key: atom group pair
    #   value: dictionary with 
    #           key: bin number
    #           value: ttoalcount in the bin for the atom group pair
    foreach grp_pair [dict keys $allPairsAggregated_counts] {
        set cur_grp_pair_counts_list [dict get $allPairsAggregated_counts $grp_pair]
        set cur_grp_pair_counts_dict [dict create]
        
        # Aggregate the counts in each group by bin numbers
        foreach item $cur_grp_pair_counts_list {
            foreach key [dict keys $item] {
                if {[dict exists $cur_grp_pair_counts_dict $key]} then {
                    dict set cur_grp_pair_counts_dict $key [expr [dict get $cur_grp_pair_counts_dict $key] + [expr [dict get $item $key] ]]
                } else {
                    dict set cur_grp_pair_counts_dict $key [expr [dict get $item $key] ]
                }
            }
        }   
        
        dict set allPairsAggregated_counts $grp_pair $cur_grp_pair_counts_dict

        # calculate the sum of counts in each element group pair
        set cur_grp_pair_counts_sum 0
        foreach grp_bin [dict keys $cur_grp_pair_counts_dict] {
            set cur_grp_pair_counts_sum [expr $cur_grp_pair_counts_sum + [dict get $cur_grp_pair_counts_dict $grp_bin]]
        }

        # Get the weight of the current element group pair
        set pair_weight [expr double($cur_grp_pair_counts_sum) / $all_distances_count]
        dict set allPairsAggregated_weights $grp_pair $pair_weight

        set grps [split $grp_pair " "]      
        if {[lindex $grps 0]==[lindex $grps 1]} {
            lappend all_same_elements_weights $pair_weight

            set cur_pair_formfactor [dict get $groupPair_formfactors $grp_pair]
            set cur_pair_formfactor_list [split [lindex $cur_pair_formfactor 0] " "]
            lappend all_same_group_pair_formfactors $cur_pair_formfactor_list
        }       
    }
    set selection_groups_weights_all_denominator $allPairsAggregated_weights

    
    # calculate unit S(q) and unit ff weighted S(q) - S(q) and ff weighted S(q) contribution from an atom if it has a count on 1 in one bin.
    for {set bin_i 0} {$bin_i < [llength $bin_totals]} {incr bin_i} {

        set cur_bin_counts_dict [dict create]
        set cur_bin_total 0
        set pair_weight [expr double([lindex $bin_totals $bin_i]) / $all_distances_count]
        
        # Compute g(r) for current bin with full count in the bin across all (i.e. all-all) pairs              
        dict append cur_bin_counts_dict $bin_i [lindex $bin_totals $bin_i]
        set partial_gofr_result [get_partial_g_r $cur_bin_counts_dict $pair_weight]
        set y_partial_gofr [lindex $partial_gofr_result 1]
        
        # Compute s(q) using above g(r)
        set partial_sofq_result [get_partial_s_q_with_contributions $y_partial_gofr $pair_weight]

        set y_partial_sofq [lindex $partial_sofq_result 1] 
        set s_q_pos_contributions [lindex $partial_sofq_result 2] 
        set s_q_neg_contributions [lindex $partial_sofq_result 3] 

        # Get the magnitude of S(q) at each q and divide it by total count to get S(q) per unit
        if {[lindex $bin_totals $bin_i]>0} then {
            set sofq_per_unit {}
            foreach sofq $y_partial_sofq {
                lappend sofq_per_unit [expr $sofq / [lindex $bin_totals $bin_i]]
            }
            dict append unit_sofqs $bin_i $sofq_per_unit
        }

        foreach pair_key [dict keys $allPairsAggregated_counts] {
            set cur_bin_counts_dict [dict create]
            set cur_pair_totals [dict get $allPairsAggregated_counts $pair_key]
            set cur_pair_bin_total 0
            if {[dict exists $cur_pair_totals $bin_i]} then {
                set cur_pair_bin_total [dict get $cur_pair_totals $bin_i]
            }
            set cur_pair_weight [expr double($cur_pair_bin_total) / $all_distances_count]

            # Compute g(r) for current bin with full count in the bin across all (i.e. all-all) pairs              
            dict append cur_bin_counts_dict $bin_i $cur_pair_bin_total
            set partial_gofr_result [get_partial_g_r $cur_bin_counts_dict $cur_pair_weight]
            set y_partial_gofr [lindex $partial_gofr_result 1]
            
            # Get the current group pair's formfactor values list
            set cur_pair_formfactor [dict get $groupPair_formfactors $pair_key]
            set cur_pair_formfactor_list [split [lindex $cur_pair_formfactor 0] " "]       

            # Compute form factor weighted s(q) using above g(r)
            set weighted_partial_sofq_result [get_formfactor_weighted_partial_s_q_with_contributions $y_partial_gofr $cur_pair_weight $cur_pair_formfactor_list]

            set y_partial_sofq [lindex $weighted_partial_sofq_result 0] 
            # set s_q_pos_contributions [lindex $partial_sofq_result 1] 
            # set s_q_neg_contributions [lindex $partial_sofq_result 2] 

            # Get the magnitude of S(q) at each q and divide it by total count to get S(q) per unit
            if {[dict exists $cur_pair_totals $bin_i]} then {
                set sofq_per_unit {}
                foreach sofq $y_partial_sofq {
                    lappend sofq_per_unit [expr $sofq / $cur_pair_bin_total]
                }

                if {[dict exists $unit_sofqs_ff $pair_key]} then {
                    set bin_cintribs_so_far [dict get $unit_sofqs_ff $pair_key]
                    dict append bin_cintribs_so_far $bin_i $sofq_per_unit
                    dict set unit_sofqs_ff $pair_key $bin_cintribs_so_far
                } else {
                    dict set cur_bin_Sq $bin_i $sofq_per_unit
                    dict append unit_sofqs_ff $pair_key $cur_bin_Sq 
                }
                
            }
        }
    }
    
    set cur_atom_count_1 [dict create]
    set atoms_count [llength [dict keys $all_atoms_counts]]
    set counter 1

    # Loop through all_atoms_counts dictionary and aggregate the counts as follows
    #   key: atom number
    #   value: dictionary of counts in each bin with all the neighbours.
    #       i.e. dictionary with 
    #               key: bin number
    #               value: list of pairs of neighbour atom number and count with the neighbour in this bin
    #               {
    #                   bin1: [(neighbour1 count) (neighbour2 count)..]
    #                   bin2: [(neighbour2 count) (neighbour4 count)..]
    #                   bin3: [(neighbour3 count) (neighbour1 count)..]
    #                   ...
    #               }
   
    foreach atom [dict keys $all_atoms_counts] {
        set cur_atom_type [dict get $atoms_groupNames "$atom"]
        set cur_atom_counts_list [dict get $all_atoms_counts $atom]
        set cur_atom_counts_dict [dict create]
        
        # Aggregate the counts in each atom by bin numbers      
        foreach item $cur_atom_counts_list {
            set paired_with_atom [lindex $item 0]
            set bin_counts [lindex $item 1]
            foreach key [dict keys $bin_counts] {
                set paired_with_atom_dict [dict create]
                if {[dict exists $cur_atom_counts_dict $key]} then {
                    set paired_with_atom_dict [dict get $cur_atom_counts_dict $key]
                    
                    if {[dict exists $paired_with_atom_dict $paired_with_atom]} then {                      
                        dict set paired_with_atom_dict $paired_with_atom [expr [dict get $paired_with_atom_dict $paired_with_atom] + [expr [dict get $bin_counts $key] / 2]]
                    } else {
                        dict append paired_with_atom_dict $paired_with_atom [expr [dict get $bin_counts $key] / 2]
                    }
                } else {
                    dict append paired_with_atom_dict $paired_with_atom [expr [dict get $bin_counts $key] /2 ]                  
                }

                dict set cur_atom_counts_dict $key $paired_with_atom_dict
                
                dict set cur_atom_count_1 $key 1
            }
        }

        # Clear the all_atoms_counts dictionary for the atom that is already processed.
        dict set all_atoms_counts $atom 0        
        set sqy {}
        set sqy_pos {}
        set sqy_neg {}
        set cur_atom_neighbours_contributions [dict create]  
        set cur_atom_neighbours_ff_contributions [dict create]        
        foreach bin_i [dict keys $cur_atom_counts_dict] {            
            set cur_bin_neighbour_counts [dict get $cur_atom_counts_dict $bin_i]

            set contribution_for_cur_bin [dict get $unit_sofqs $bin_i]
            foreach neighbour [dict keys $cur_bin_neighbour_counts] {  
                set atom_pair_key ""
                set cur_neighbor_type [dict get $atoms_groupNames "$neighbour"]
                set possible_pair "$cur_atom_type $cur_neighbor_type"
                set possible_pair_reverse "$cur_neighbor_type $cur_atom_type"
                if { [dict exists $allPairsAggregated_counts $possible_pair] ==1 } then {
                    set atom_pair_key $possible_pair
                } else {
                    set atom_pair_key $possible_pair_reverse
                } 

                # Calculate the current neighbour contribution using its count and unit S(q).  
                set neighbour_contribution_for_cur_bin {}              
                foreach cur_unit_sofq $contribution_for_cur_bin {
                    lappend neighbour_contribution_for_cur_bin [expr [dict get $cur_bin_neighbour_counts $neighbour] * $cur_unit_sofq]
                }

                set contribution_for_cur_pair [dict get $unit_sofqs_ff $atom_pair_key]
                if {[dict exists $contribution_for_cur_pair $bin_i] ==1} {
                    # Calculate the current neighbour ff weighted contribution using its count and ff weighted unit S(q).  
                    set neighbour_contribution_for_cur_bin_ff {}  
                    set contribution_for_cur_pair_cur_bin [dict get $contribution_for_cur_pair $bin_i]          
                    foreach cur_unit_sofq $contribution_for_cur_pair_cur_bin {
                        # puts "$atom_pair_key  $bin_i  $cur_unit_sofq"
                        lappend neighbour_contribution_for_cur_bin_ff [expr [dict get $cur_bin_neighbour_counts $neighbour] * $cur_unit_sofq]
                    }

                    # keep the running total contribution of an atom from its neighbours contributions.
                    if {[dict exists $cur_atom_neighbours_ff_contributions $neighbour]} then {
                        set neighbour_existing_ff_contribution [dict get $cur_atom_neighbours_ff_contributions $neighbour]
                        for {set q 0} {$q < [llength $neighbour_existing_ff_contribution]} {incr q} {
                            lset neighbour_existing_ff_contribution $q [expr [lindex $neighbour_existing_ff_contribution $q] + [lindex $neighbour_contribution_for_cur_bin_ff $q]]
                        }
                        dict set cur_atom_neighbours_ff_contributions $neighbour $neighbour_existing_ff_contribution
                    } else {
                        dict set cur_atom_neighbours_ff_contributions $neighbour $neighbour_contribution_for_cur_bin_ff
                    } 
                }

                # keep the running total contribution of an atom from its neighbours contributions.
                if {[dict exists $cur_atom_neighbours_contributions $neighbour]} then {
                    set neighbour_existing_contribution [dict get $cur_atom_neighbours_contributions $neighbour]
                    for {set q 0} {$q < [llength $neighbour_existing_contribution]} {incr q} {
                        lset neighbour_existing_contribution $q [expr [lindex $neighbour_existing_contribution $q] + [lindex $neighbour_contribution_for_cur_bin $q]]
                    }
                    dict set cur_atom_neighbours_contributions $neighbour $neighbour_existing_contribution
                } else {
                    dict set cur_atom_neighbours_contributions $neighbour $neighbour_contribution_for_cur_bin
                }
            }
        }

        # write the neighbours contributions to the current atom to the file.
        if {$write_to_file == 1} then {
            # puts "writing to file..."
            set atom_contribution {}
            set atom_contribution_ff {}
            set out_line $atom
            set out_line_ff $atom
            append out_line " {"
            append out_line_ff " {"
            foreach neighbour [dict keys $cur_atom_neighbours_contributions] {
                set new_sofq [dict get $cur_atom_neighbours_contributions $neighbour]
                if {[llength $atom_contribution]==0} then {                         
                    set atom_contribution $new_sofq
                } else {
                    for {set q 0} {$q < [llength $atom_contribution]} {incr q} {
                        lset atom_contribution $q [expr [lindex $atom_contribution $q] + [lindex $new_sofq $q]]
                    }
                } 
                append out_line $neighbour
                append out_line " {"
                append out_line [join $new_sofq " "]  
                append out_line "} "                      
            }
            append out_line "}" 

            puts $fp $out_line

            foreach neighbour [dict keys $cur_atom_neighbours_ff_contributions ] {
                set new_sofq [dict get $cur_atom_neighbours_ff_contributions $neighbour]
                if {[llength $atom_contribution_ff]==0} then {                         
                    set atom_contribution_ff $new_sofq
                } else {
                    for {set q 0} {$q < [llength $atom_contribution_ff]} {incr q} {
                        lset atom_contribution_ff $q [expr [lindex $atom_contribution_ff $q] + [lindex $new_sofq $q]]
                    }
                } 
                append out_line_ff $neighbour
                append out_line_ff " {"
                append out_line_ff [join $new_sofq " "]  
                append out_line_ff "} "                      
            }
            append out_line_ff "}" 

            puts $fp1 $out_line_ff
        }
        dict set all_atom_contributions $atom [list $atom_contribution {} {}]
        dict set all_atom_contributions_ff $atom [list $atom_contribution_ff {} {}]

        if {[expr $counter%100]==0} {
            puts "$counter out of $atoms_count atoms processed."
        }
        incr counter
    }
    set all_atoms_counts [dict create]
    
    if {$write_to_file == 1} then {
        close $fp1
        close $fp
    }

    set auto_call 0    
}

# Counts Dictionary format:
#   {
#       type1-type1: [bin:count bin:count]
#       type1-type2: [bin:count bin:count]
#       type2-type2: [bin:count bin:count]
#   }
#
# Weights Dictionary format:
#   {
#       type1-type1: weight
#       type1-type2: weight
#       type2-type2: weight
#   }
proc ::SQGUI::computePartialsForSelections {counts_dict weights_dict} {

    global groupPair_formfactors
    global group_pair_s_q
    global ff_weighted_group_pair_s_q
    global selection_S_q_pos_contributions
    global selection_S_q_neg_contributions  
    global selection_weighted_S_q_pos_contributions
    global selection_weighted_S_q_neg_contributions 
    global rbin_contributions_for_total_S_q
    global rbin_contributions_for_ff_weighted_S_q
    global selection_groups_weights_all_denominator
    global all_same_elements_weights
    global all_same_group_pair_formfactors

    variable input_file_path    
    variable cannotplot
    variable SQ_plot
    variable auto_call
    variable total_distances_count
    variable selection1
    variable selection2
    variable subselection1
    variable subselection2

    set group_pair_g_r [dict create]
    set weighted_group_pair_g_r [dict create]
    set group_pair_s_q {}
    set ff_weighted_group_pair_s_q [dict create]
    set rbin_contributions_for_total_S_q {}
    set rbin_contributions_for_ff_weighted_S_q {}
    set selection_S_q_pos_contributions [dict create]
    set selection_S_q_neg_contributions [dict create]
    set selection_weighted_S_q_pos_contributions [dict create]
    set selection_weighted_S_q_neg_contributions [dict create]
    set y_weighted_partial_sofq_sum {}
    set x_total_gofr {}
    set y_total_gofr {}
    set x_total_sofq {}
    set y_total_sofq {}

    set unweighted_contributions_file $input_file_path
    append unweighted_contributions_file "r_contributions_sq.dat"
    set weighted_contributions_file $input_file_path
    append weighted_contributions_file "r_contributions_form_factor_sq.dat"

    #delete contributions files if they exist!
    file delete $unweighted_contributions_file
    file delete $weighted_contributions_file

    set sel1_20 [string range $selection1 0 20]
    set sel2_20 [string range $selection2 0 20]
    set subsel1_20 [string range $subselection1 0 20]
    set subsel2_20 [string range $subselection2 0 20]
    set counter 1
    set grp_pairs_count [llength [dict keys $counts_dict]]

    set selections_all_bin_values [dict create]

    # Merging all the group pair counts in to one single dictionary
    foreach grp_pair [dict keys $counts_dict] {
        set cur_grp_pair_counts_dict [dict get $counts_dict $grp_pair]
        foreach bin [dict keys $cur_grp_pair_counts_dict] {
            set cur_bin_val [dict get $cur_grp_pair_counts_dict $bin]
            if {[dict exists $selections_all_bin_values $bin]} then {
                dict set selections_all_bin_values $bin [expr [dict get $selections_all_bin_values $bin]+$cur_bin_val]
            } else {
                dict append selections_all_bin_values $bin $cur_bin_val
            }
        }
    }

    # Calculate g(r) for all the counts in the selections
    set total_gofr_result [get_partial_g_r $selections_all_bin_values 1]
    set x_total_gofr [lindex $total_gofr_result 0]
    set y_total_gofr [lindex $total_gofr_result 1]
    
    # Calculate non FF weighted S(q) for all the counts in the selections
    set total_sofq_result [get_partial_s_q_with_contributions $y_total_gofr 1]
    set x_total_sofq [lindex $total_sofq_result 0]
    set y_total_sofq [lindex $total_sofq_result 1]
    set pos_contributions [lindex $total_sofq_result 2]
    set neg_contributions [lindex $total_sofq_result 3]
    set rbin_contributions_for_total_S_q [lindex $total_sofq_result 4]

    # Convert positive and negative contributions arrays into dictonaries for consistent processing in later stages
    for {set i 0} {$i < [llength $pos_contributions]} {incr i} {
        dict append selection_S_q_pos_contributions [lindex $x_total_sofq $i] [lindex $pos_contributions $i]
    }
    for {set i 0} {$i < [llength $neg_contributions]} {incr i} {
        dict append selection_S_q_neg_contributions [lindex $x_total_sofq $i] [lindex $neg_contributions $i]
    }

    # Save the non FF S(q) for future use during displaying statistics in table.
    set group_pair_s_q $y_total_sofq

    # Calculate FF weighted S(q) for each group pair and sum them.
    foreach grp_pair [dict keys $counts_dict] {      
       
        set cur_grp_pair_counts_dict [dict get $counts_dict $grp_pair]
        set pair_weight_all_denominator [dict get $selection_groups_weights_all_denominator $grp_pair]

        # Get the current group pair's formfactor values list
        set cur_pair_formfactor [dict get $groupPair_formfactors $grp_pair]
        set cur_pair_formfactor_list [split [lindex $cur_pair_formfactor 0] " "]       

        # Calculate partuial g(r) using all-case weights for form-factor weighted S(q)
        set partial_gofr_result_all [get_partial_g_r $cur_grp_pair_counts_dict $pair_weight_all_denominator]            
        set y_partial_gofr_all [lindex $partial_gofr_result_all 1]

        # Compute form factor weighted s(q) for current group pair
        set weighted_partial_sofq_result [get_formfactor_weighted_partial_s_q $y_partial_gofr_all $pair_weight_all_denominator $cur_pair_formfactor_list "" $grp_pair]

        set x_weighted_partial_sofq [lindex $weighted_partial_sofq_result 0]
        set y_weighted_partial_sofq [lindex $weighted_partial_sofq_result 1]
        set ff_weighted_rbin_contributions [lindex $weighted_partial_sofq_result 2]

        dict append ff_weighted_group_pair_s_q $grp_pair $y_weighted_partial_sofq

        if { [llength $y_weighted_partial_sofq_sum] == 0 } then {
            set y_weighted_partial_sofq_sum $y_weighted_partial_sofq
        } else {
            for {set i 0} {$i < [llength $y_weighted_partial_sofq_sum]} {incr i} {
                lset y_weighted_partial_sofq_sum $i [expr [lindex $y_weighted_partial_sofq $i] + [lindex $y_weighted_partial_sofq_sum $i]]
            }
        }

        if {[llength $rbin_contributions_for_ff_weighted_S_q]==0} then {
            set rbin_contributions_for_ff_weighted_S_q $ff_weighted_rbin_contributions
        } else {
            for {set i_contribution 0} {$i_contribution < [llength $rbin_contributions_for_ff_weighted_S_q]} {incr i_contribution} {            
                set rbins_for_q_so_far [lindex $rbin_contributions_for_ff_weighted_S_q $i_contribution]
                set rbins_for_q_new [lindex $ff_weighted_rbin_contributions $i_contribution]
                for {set q 0} {$q < [llength $rbins_for_q_new]} {incr q} {
                    lset rbins_for_q_so_far $q [expr [lindex $rbins_for_q_so_far $q] + [lindex $rbins_for_q_new $q]]
                }

                lset rbin_contributions_for_ff_weighted_S_q $i_contribution $rbins_for_q_so_far
            }
        }
       
    }

    if {$cannotplot} then {
        tk_dialog .errmsg {viewSq Error} "Multiplot is not available." error 0 Dismiss
    } else { 
        set addToTitle ""
        # If auto_call is
        #   True: the call came from selections and we have to plot all the graphs.
        #   False: the call came from "Compute S(q)" and plot only ff weighted S(q) plot.
        if {$auto_call} then {
            set addToTitle "for the selection "
            # plot total g(r) for the selections
            set selection_total_gofr_plot [multiplot -x $x_total_gofr -y $y_total_gofr -title "Selections - g(r) plot (total atomic distances: $total_distances_count, $sel1_20-$sel2_20)" -lines -linewidth 2 -marker point -plot]

            # plot total s(q) for the selections
            set selection_total_sofq_plot [multiplot -x $x_total_sofq -y $y_total_sofq -title "Selections - S(q) and form factor weighted S(q) plot ($sel1_20-$sel2_20)" \
                                                    -legend "S(q)" -lines -linewidth 3 -marker point -plot]

            # plot form factor weighted s(q) for the selections on the same plot as total s(q) for the selections
            $selection_total_sofq_plot add $x_total_sofq $y_weighted_partial_sofq_sum -lines -linewidth 2 -linecolor blue -legend "Form factor weighted S(q) ($sel1_20-$sel2_20)" -marker point -plot
            
            # plot positive and negative contributions to s(q) at each q separately
            set selection_S_q_pos_contributions_y [dict values $selection_S_q_pos_contributions]
            set selection_S_q_neg_contributions_y [dict values $selection_S_q_neg_contributions]        
            set SQ_plot_pos_neg_contributions [multiplot -x [dict keys $selection_S_q_pos_contributions] -y $selection_S_q_pos_contributions_y -title "Selections - positive and negative contributions to S(q) ($sel1_20-$sel2_20)" \
                                                    -lines -linewidth 2 -marker point -linecolor green -legend "Positive Contribution" -fillcolor black]
            $SQ_plot_pos_neg_contributions add [dict keys $selection_S_q_pos_contributions] $selection_S_q_neg_contributions_y -lines -linewidth 2 \
                                                    -legend "Negative Contribution" -marker point -linecolor red -fillcolor black -plot

            # plot sum of positive and magnitude of negative contributions to s(q) at each q
            set S_q_pos_abs_neg_contributions $selection_S_q_pos_contributions_y
            set k_idx 0
            foreach neg_value $selection_S_q_neg_contributions_y {
                lset S_q_pos_abs_neg_contributions $k_idx [expr abs($neg_value) + [lindex $S_q_pos_abs_neg_contributions $k_idx] ]
                incr k_idx
            }
            set SQ_plot_pos_abs_neg_contributions [multiplot -x [dict keys $selection_S_q_pos_contributions] -y $S_q_pos_abs_neg_contributions \
                                                    -title "Selections - sum of positive and magnitude of negative contributions to S(q) ($sel1_20-$sel2_20)" -lines -linewidth 2 -marker point -plot ]                  
        } else {
           $SQ_plot add $x_total_sofq $y_weighted_partial_sofq_sum -lines -linewidth 2 -linecolor blue -marker point -legend "Form Factor Weighted S(q)" -plot
        }

        # plot positive and negative contributions to form factor weighted s(q) at each q separately
        set selection_weighted_S_q_pos_contributions_y [dict values $selection_weighted_S_q_pos_contributions]
        set selection__weighted_S_q_neg_contributions_y [dict values $selection_weighted_S_q_neg_contributions]     
        set ff_weighted_SQ_plot_pos_neg_contributions [multiplot -x [dict keys $selection_weighted_S_q_pos_contributions] -y $selection_weighted_S_q_pos_contributions_y \
            -title "positive and negative contributions for form factor weighted S(q) ${addToTitle} plot ($sel1_20-$sel2_20)" \
            -legend "Positive Contribution" -lines -linewidth 2 -marker point -linecolor green -fillcolor black]
        $ff_weighted_SQ_plot_pos_neg_contributions add [dict keys $selection_weighted_S_q_pos_contributions] $selection__weighted_S_q_neg_contributions_y \
            -legend "Negative Contribution" -lines -linewidth 2 -marker point -linecolor red -fillcolor black -plot

        # plot sum of positive and magnitude of negative contributions to forma factor weighted s(q) at each q
        set ff_weighted_S_q_pos_abs_neg_contributions $selection_weighted_S_q_pos_contributions_y
        set k_idx 0
        foreach neg_value $selection__weighted_S_q_neg_contributions_y {
            lset ff_weighted_S_q_pos_abs_neg_contributions $k_idx [expr abs($neg_value) + [lindex $ff_weighted_S_q_pos_abs_neg_contributions $k_idx] ]
            incr k_idx
        }
        set ff_weighted_SQ_plot_pos_abs_neg_contributions [multiplot -x [dict keys $selection_weighted_S_q_pos_contributions] -y $ff_weighted_S_q_pos_abs_neg_contributions \
            -title "Sum of positive and magnitude of negative contributions for form factor weighted S(q) ${addToTitle} plot ($sel1_20-$sel2_20)" \
            -lines -linewidth 2 -marker point -plot ]
        
    }           
}

proc ::SQGUI::printatomCounts {atoms_sel1 atoms_sel2 atoms_subSel1 atoms_subSel2} {
    puts "Number of atoms in selection1: $atoms_sel1   Number of atoms in selection2: $atoms_sel2"
    puts "Number of atoms in subselection1: $atoms_subSel1   Number of atoms in subselection2: $atoms_subSel2"    
}

proc ::SQGUI::printdistanceCounts {selectionDistances subSelectionDistances all_distances_count} {
    set subSelectionPercent_Total [expr {double(round(10000 * [expr double($subSelectionDistances) / $all_distances_count]))/100}]
    set subSelectionPercent_Selection [expr {double(round(10000 * [expr double($subSelectionDistances) / $selectionDistances]))/100}]
    puts "Distances in subselection: $subSelectionDistances   Distances in selection: $selectionDistances   Total Distances in bins: $all_distances_count"
    puts "Percent subselection of Selection: $subSelectionPercent_Selection   Percent subselection of Total Distances in bins: $subSelectionPercent_Total"
}

##### set selection_atom_contributions dict to non-FF / FF based on the UI selection.
proc ::SQGUI::computeSelections {} {

    global bin_totals
    global atoms_groupNames
    global groups_atomNos
    global subGroupPair_counts    
    global groupPair_formfactors 
    global allPairsAggregated_counts
    global allPairsAggregated_weights
    global all_same_elements_weights
    global all_same_group_pair_formfactors
    global all_atoms_counts
    global selection_atoms_counts
    global selection_atom_contributions
    global all_atom_contributions
    global all_atom_contributions_ff
    global possible_sq_contribution_differences
    global selection_groups_weights_all_denominator
    global atom_numbers_sel1
    global atom_numbers_sel2

    variable w
    variable min_q
    variable max_q
    variable delta
    variable delta_q
    variable num_atoms
    variable auto_call
    variable molid
    variable selection1
    variable selection2 
    variable subselection1
    variable subselection2 
    variable rbinRange
    variable total_distances_count
    variable all_distances_count
    variable input_file_path
    variable enableStatistics
    variable enableRankings
    variable useNonFFSq

    set atoms_sel1 0
    set atoms_sel2 0
    set atoms_subSel1 0
    set atoms_subSel2 0

    set selection_groups_counts [dict create]
    set selection_atoms_counts [dict create]
    set selection_groups_weights [dict create]
    set selection_groups_same_elements_weights {}
    set same_group_pair_formfactors {} 
    set selection_atom_contributions [dict create]
    set selection_groups_weights_all_denominator [dict create]
    set atom_numbers_sel1 {}
    set atom_numbers_sel2 {}
    set auto_call 1
    set pair_weight 1
    set num_atoms_in_selection 0

    set subSelectionPercent_Total 0
    set subSelectionDistances 0
    set selectionDistances 0
    set subSelectionPercent_Selection 0
    set total_distances_count 0

    puts "\nCalculating partials for selections..."
    if {$selection1=="all" && $selection2=="all"} then {    
        set total_distances_count $all_distances_count    
        set selectionDistances $total_distances_count    
        if {$subselection1 =="all" && $subselection2=="all" && $rbinRange=="all"} then {              
            set subSelectionDistances $total_distances_count   
            set atoms_sel1 $num_atoms
            set atoms_sel2 $num_atoms
            set atoms_subSel1 $num_atoms
            set atoms_subSel2 $num_atoms
            set sel1 [atomselect $molid "$selection1"]
            set sel2 [atomselect $molid "$selection2"]
            set atom_numbers_sel1 [$sel1 get serial]
            set atom_numbers_sel2 [$sel2 get serial]
        } else {
            set selection_done 0
            # Check if the selection string contains the delimeters ':' or ','. 
            # If yes, parse the string and create selection.
            # Else, Use the VMD's selection.
            set customSelections [split $subselection1 ":"]
            set selStr "serial "
            foreach c_sel $customSelections {
                set components [split $c_sel ","]
                if {[llength $components]<3} then {
                    if {[catch {atomselect $molid "$subselection1"} subSel1]} then {
                        tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$subselection1" error 0 Dismiss
                        return
                    }
                    set selection_done 1
                    break
                } else {
                    set sel_idx 0                    
                    for {set sel_start [lindex $components 0]} {$sel_idx < [lindex $components 2]} {incr sel_start [lindex $components 1]} {
                        append selStr "$sel_start "
                        incr sel_idx
                    }                    
                }
            }
            if {$selection_done==0} {
                if {[catch {atomselect $molid "$selStr"} subSel1]} then {
                    tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$subselection1" error 0 Dismiss
                    return
                }
            }

            set selection_done 0
            set customSelections [split $subselection2 ":"]
            set selStr "serial "
            foreach c_sel $customSelections {
                set components [split $c_sel ","]
                if {[llength $components]<3} then {
                    if {[catch {atomselect $molid "$subselection2"} subSel2]} then {
                        tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$subselection2" error 0 Dismiss
                        return
                    }
                    set selection_done 1
                    break
                } else {
                    set sel_idx 0                    
                    for {set sel_start [lindex $components 0]} {$sel_idx < [lindex $components 2]} {incr sel_start [lindex $components 1]} {
                        append selStr "$sel_start "
                        incr sel_idx
                    }
                }
            }
            if {$selection_done==0} {
                if {[catch {atomselect $molid "$selStr"} subSel2]} then {
                    tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$subselection2" error 0 Dismiss
                    return
                }
            }

            if {[catch {atomselect $molid "$selection1"} sel1] \
                    || [catch {atomselect $molid "$selection2"} sel2] } then {
                tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$selection1\n$selection2" error 0 Dismiss
                return
            }            

            set atom_numbers_sel1 [$sel1 get serial]
            set atom_numbers_sel2 [$sel2 get serial]
            set atom_numbers_subSel1 [$subSel1 get serial]
            set atom_numbers_subSel2 [$subSel2 get serial] 
            set counts_yes 0
            set counts_no 0
            foreach atom_k $atom_numbers_sel1 {
                if {(([lsearch -exact $atom_numbers_subSel1 $atom_k] >= 0 )&&([lsearch -exact $atom_numbers_subSel2 $atom_k] >= 0 ))} {
                    incr atoms_subSel1
                }
            }
            foreach atom_k $atom_numbers_sel2 {
                if {(([lsearch -exact $atom_numbers_subSel1 $atom_k] >= 0 )&&([lsearch -exact $atom_numbers_subSel2 $atom_k] >= 0 ))} {
                    incr atoms_subSel2
                }
            }

            foreach atom_i $atom_numbers_sel1 {
                set atom_i_grp [dict get $atoms_groupNames $atom_i]
                set atom_i_grp [string range $atom_i_grp 1 [expr [string length $atom_i_grp] -2]]
                foreach atom_j $atom_numbers_sel2 {
                    if {$atom_i != $atom_j } {
                        set inSubSelection 0
                        set atom_j_grp [dict get $atoms_groupNames $atom_j]
                        set atom_j_grp [string range $atom_j_grp 1 [expr [string length $atom_j_grp] -2]]
                        set subgrp_pair "\[${atom_i_grp}:${atom_i}\] \[${atom_j_grp}:${atom_j}\]"
                        set subgrp_pair_reverse "\[${atom_j_grp}:${atom_j}\] \[${atom_i_grp}:${atom_i}\]"
                        set grp_pair "\[${atom_i_grp}\] \[${atom_j_grp}\]"
                        set grp_pair_reverse "\[${atom_j_grp}\] \[${atom_i_grp}\]"
                        if {(([lsearch -exact $atom_numbers_subSel1 $atom_i] >= 0 )&&([lsearch -exact $atom_numbers_subSel2 $atom_j] >= 0 )) || 
                            (([lsearch -exact $atom_numbers_subSel2 $atom_i] >= 0 )&&([lsearch -exact $atom_numbers_subSel1 $atom_j] >= 0 ))} {
                            set inSubSelection 1
                        }
                        
                        set counts [dict create]
                        set hasCounts 0
                        if { [dict exists $subGroupPair_counts $subgrp_pair] ==1 } then {                       
                            set counts [dict get $subGroupPair_counts $subgrp_pair]     
                            set hasCounts 1                                    
                        } elseif { [dict exists $subGroupPair_counts $subgrp_pair_reverse] ==1 } then {
                            set counts [dict get $subGroupPair_counts $subgrp_pair_reverse]         
                            set hasCounts 1
                        }

                        if {$hasCounts ==1} then {
                            if { [dict exists $selection_groups_counts $grp_pair] ==1 } then {
                                dict lappend selection_groups_counts $grp_pair $counts  
                            } elseif { [dict exists $selection_groups_counts $grp_pair_reverse] ==1 } then {    
                                dict lappend selection_groups_counts $grp_pair_reverse $counts
                            } else {
                                dict lappend selection_groups_counts $grp_pair $counts              
                            }   
                            
                            if { $inSubSelection } then {
                                if {$rbinRange=="all"} then {
                                    if {$subselection1!=$subselection2} {
                                        set subSelectionDistances [expr $subSelectionDistances + [ladd [dict values $counts]]]
                                    } else {
                                        set subSelectionDistances [expr $subSelectionDistances + [expr [ladd [dict values $counts]]/2]]
                                    }
                                } else {
                                    set binsOfInterest {}
                                    set binRanges [split $rbinRange ","]                                
                                    foreach binRange $binRanges {
                                        set binIndices [split $binRange "-"]
                                        if {[llength $binIndices]>1} then {
                                            set minSelectedR [expr int([expr [lindex $binIndices 0] / $delta])]
                                            set maxSelectedR [expr int([expr [lindex $binIndices 1] / $delta])]
                                            for {set b $minSelectedR} {$b <= $maxSelectedR} {incr b} {
                                                # puts "$b"
                                                lappend binsOfInterest $b
                                            }
                                        } else {
                                            lappend binsOfInterest [expr int([expr $binIndices / $delta])]
                                        }
                                    }    

                                    foreach bin_key [dict keys $counts] {
                                        if {[lsearch -exact $binsOfInterest $bin_key] >= 0} {
                                            if {$subselection1!=$subselection2} {
                                                set subSelectionDistances [expr $subSelectionDistances + [dict values $counts]]
                                            } else {
                                                set subSelectionDistances [expr $subSelectionDistances + [expr [dict get $counts $bin_key]/2]]
                                            }
                                        }                                    
                                    }                                
                                }                                
                            }           
                        }               
                    }
                }
            }
        }
        set atoms_sel1 $num_atoms
        set atoms_sel2 $num_atoms
        if {$useNonFFSq} then {
            set selection_atom_contributions $all_atom_contributions    
        } else {
            set selection_atom_contributions $all_atom_contributions_ff
        }
        
        set num_atoms_in_selection $num_atoms
        set selection_groups_weights_all_denominator $allPairsAggregated_weights
        printatomCounts $atoms_sel1 $atoms_sel2 $atoms_subSel1 $atoms_subSel2
        printdistanceCounts $selectionDistances $subSelectionDistances $all_distances_count        
        computePartialsForSelections $allPairsAggregated_counts $allPairsAggregated_weights
        puts "Completed!\n"
    } else {
        set selection_done 0
        # Check if the selection string contains the delimeters ':' or ','. 
        # If yes, parse the string and create selection.
        # Else, Use the VMD's selection.
        set customSelections [split $selection1 ":"]
        set selStr "serial "
        foreach c_sel $customSelections {
            set components [split $c_sel ","]
            if {[llength $components]<3} then {
                if {[catch {atomselect $molid "$selection1"} sel1]} then {
                    tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$selection1" error 0 Dismiss
                    return
                }
                set selection_done 1
                break
            } else {
                set sel_idx 0                    
                for {set sel_start [lindex $components 0]} {$sel_idx < [lindex $components 2]} {incr sel_start [lindex $components 1]} {
                    append selStr "$sel_start "
                    incr sel_idx
                }                    
            }
        }
        if {$selection_done==0} {
            if {[catch {atomselect $molid "$selStr"} sel1]} then {
                tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$selection1" error 0 Dismiss
                return
            }
        }

        set selection_done 0
        set customSelections [split $selection2 ":"]
        set selStr "serial "
        foreach c_sel $customSelections {
            set components [split $c_sel ","]
            if {[llength $components]<3} then {
                if {[catch {atomselect $molid "$selection2"} sel2]} then {
                    tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$selection2" error 0 Dismiss
                    return
                }
                set selection_done 1
                break
            } else {
                set sel_idx 0                    
                for {set sel_start [lindex $components 0]} {$sel_idx < [lindex $components 2]} {incr sel_start [lindex $components 1]} {
                    append selStr "$sel_start "
                    incr sel_idx
                }
            }
        }
        if {$selection_done==0} {
            if {[catch {atomselect $molid "$selStr"} sel2]} then {
                tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$selection2" error 0 Dismiss
                return
            }
        }

        set selection_done 0
        set customSelections [split $subselection1 ":"]
        set selStr "serial "
        foreach c_sel $customSelections {
            set components [split $c_sel ","]
            if {[llength $components]<3} then {
                if {[catch {atomselect $molid "$subselection1"} subSel1]} then {
                    tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$subselection1" error 0 Dismiss
                    return
                }
                set selection_done 1
                break
            } else {
                set sel_idx 0                    
                for {set sel_start [lindex $components 0]} {$sel_idx < [lindex $components 2]} {incr sel_start [lindex $components 1]} {
                    append selStr "$sel_start "
                    incr sel_idx
                }
            }
        }
        if {$selection_done==0} {
            if {[catch {atomselect $molid "$selStr"} subSel1 ]} then {
                tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$subselection1" error 0 Dismiss
                return
            }
        }

        set selection_done 0
        set customSelections [split $subselection2 ":"]
        set selStr "serial "
        foreach c_sel $customSelections {
            set components [split $c_sel ","]
            if {[llength $components]<3} then {
                if {[catch {atomselect $molid "$subselection2"} subSel2]} then {
                    tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$subselection2" error 0 Dismiss
                    return
                }
                set selection_done 1
                break
            } else {
                set sel_idx 0                    
                for {set sel_start [lindex $components 0]} {$sel_idx < [lindex $components 2]} {incr sel_start [lindex $components 1]} {
                    append selStr "$sel_start "
                    incr sel_idx
                }
            }
        }
        if {$selection_done==0} {
            if {[catch {atomselect $molid "$selStr"} subSel2 ]} then {
                tk_dialog .errmsg {viewSq Error} "There was an error creating the selections:\n$subselection2" error 0 Dismiss
                return
            }
        }
        
        set atom_numbers_sel1 [$sel1 get serial]
        set atom_numbers_sel2 [$sel2 get serial]
        set atom_numbers_subSel1 [$subSel1 get serial]
        set atom_numbers_subSel2 [$subSel2 get serial]        
        set counts_yes 0
        set counts_no 0        
        set atoms_sel1 [llength $atom_numbers_sel1]
        set atoms_sel2 [llength $atom_numbers_sel2]
        foreach atom_k $atom_numbers_subSel1 {
            if {([lsearch -exact $atom_numbers_sel1 $atom_k] >= 0)} {
                incr atoms_subSel1
            }
        }
        foreach atom_k $atom_numbers_subSel2 {
            if {([lsearch -exact $atom_numbers_sel2 $atom_k] >= 0 )} {
                incr atoms_subSel2
            }
        }
        printatomCounts $atoms_sel1 $atoms_sel2 $atoms_subSel1 $atoms_subSel2

        set counter 1
        set processed_sub_group_pairs {}

        # if the selections are same - make the loop as i-> 1-n and j-> i+1-n
        # else run both the loops to entire length of each list
        if {$selection1==$selection2} then {
            for {set i 0} {$i < [llength $atom_numbers_sel1]} {incr i} {
                for {set j [expr $i+1]} {$j < [llength $atom_numbers_sel2]} {incr j} {
                    set inSubSelection 0
                    set atom_i [lindex $atom_numbers_sel1 $i]
                    set atom_j [lindex $atom_numbers_sel2 $j] 
                    set atom_i_grp [dict get $atoms_groupNames $atom_i]
                    set atom_i_grp [string range $atom_i_grp 1 [expr [string length $atom_i_grp] -2]]
                    set atom_j_grp [dict get $atoms_groupNames $atom_j]
                    set atom_j_grp [string range $atom_j_grp 1 [expr [string length $atom_j_grp] -2]]
                    set subgrp_pair "\[${atom_i_grp}:${atom_i}\] \[${atom_j_grp}:${atom_j}\]"
                    set subgrp_pair_reverse "\[${atom_j_grp}:${atom_j}\] \[${atom_i_grp}:${atom_i}\]"
                    set grp_pair "\[${atom_i_grp}\] \[${atom_j_grp}\]"
                    set grp_pair_reverse "\[${atom_j_grp}\] \[${atom_i_grp}\]"
                    if {(([lsearch -exact $atom_numbers_subSel1 $atom_i] >= 0 )&&([lsearch -exact $atom_numbers_subSel2 $atom_j] >= 0 )) || 
                        (([lsearch -exact $atom_numbers_subSel2 $atom_i] >= 0 )&&([lsearch -exact $atom_numbers_subSel1 $atom_j] >= 0 ))} {
                        set inSubSelection 1
                    }

                    set counts [dict create]
                    set hasCounts 0
                    if { [dict exists $subGroupPair_counts $subgrp_pair] ==1 } then {                       
                        set counts [dict get $subGroupPair_counts $subgrp_pair]     
                        set hasCounts 1
                    } elseif { [dict exists $subGroupPair_counts $subgrp_pair_reverse] ==1 } then {
                        set counts [dict get $subGroupPair_counts $subgrp_pair_reverse]         
                        set hasCounts 1
                    set hasCounts 0
                    if { [dict exists $subGroupPair_counts $subgrp_pair] ==1 } then {                       
                        set counts [dict get $subGroupPair_counts $subgrp_pair]     
                        set hasCounts 1
                    } elseif { [dict exists $subGroupPair_counts $subgrp_pair_reverse] ==1 } then {
                        set counts [dict get $subGroupPair_counts $subgrp_pair_reverse]         
                        set hasCounts 1
                    }

                    if {$hasCounts ==1} then {
                        set selectionDistances [expr $selectionDistances + [ladd [dict values $counts]]]
                        
                        if { [dict exists $selection_groups_counts $grp_pair] ==1 } then {
                            dict lappend selection_groups_counts $grp_pair $counts  
                        } elseif { [dict exists $selection_groups_counts $grp_pair_reverse] ==1 } then {    
                            dict lappend selection_groups_counts $grp_pair_reverse $counts
                        } else {
                            dict lappend selection_groups_counts $grp_pair $counts              
                        }

                        dict set selection_atom_contributions $atom_i 0
                        dict set selection_atom_contributions $atom_j 0     
                        
                        if { $inSubSelection } then {
                            if {$rbinRange=="all"} then {
                                set subSelectionDistances [expr $subSelectionDistances + [ladd [dict values $counts]]]
                            } else {
                                set binsOfInterest {}
                                set binRanges [split $rbinRange ","]                                
                                foreach binRange $binRanges {
                                    set binIndices [split $binRange "-"]
                                    if {[llength $binIndices]>1} then {
                                        set minSelectedR [expr int([expr [lindex $binIndices 0] / $delta])]
                                        set maxSelectedR [expr int([expr [lindex $binIndices 1] / $delta])]
                                        for {set b $minSelectedR} {$b <= $maxSelectedR} {incr b} {                                        
                                            lappend binsOfInterest $b
                                        }
                                    } else {
                                        lappend binsOfInterest [expr int([expr $binIndices / $delta])]
                                    }
                                }
                                
                                foreach bin_key [dict keys $counts] {
                                    if {[lsearch -exact $binsOfInterest $bin_key] >= 0} {                                        
                                        set subSelectionDistances [expr $subSelectionDistances + [dict values $counts]]
                                    }                                    
                                }                                
                            }  
                        }           
                    } }

                    if {$hasCounts ==1} then {
                        set selectionDistances [expr $selectionDistances + [ladd [dict values $counts]]]
                        
                        if { [dict exists $selection_groups_counts $grp_pair] ==1 } then {
                            dict lappend selection_groups_counts $grp_pair $counts  
                        } elseif { [dict exists $selection_groups_counts $grp_pair_reverse] ==1 } then {    
                            dict lappend selection_groups_counts $grp_pair_reverse $counts
                        } else {
                            dict lappend selection_groups_counts $grp_pair $counts              
                        }

                        dict set selection_atom_contributions $atom_i 0
                        dict set selection_atom_contributions $atom_j 0     
                        
                        if { $inSubSelection } then {
                            if {$rbinRange=="all"} then {
                                set subSelectionDistances [expr $subSelectionDistances + [ladd [dict values $counts]]]
                            } else {
                                set binsOfInterest {}
                                set binRanges [split $rbinRange ","]                                
                                foreach binRange $binRanges {
                                    set binIndices [split $binRange "-"]
                                    if {[llength $binIndices]>1} then {
                                        set minSelectedR [expr int([expr [lindex $binIndices 0] / $delta])]
                                        set maxSelectedR [expr int([expr [lindex $binIndices 1] / $delta])]
                                        for {set b $minSelectedR} {$b <= $maxSelectedR} {incr b} {                                        
                                            lappend binsOfInterest $b
                                        }
                                    } else {
                                        lappend binsOfInterest [expr int([expr $binIndices / $delta])]
                                    }
                                }
                                
                                foreach bin_key [dict keys $counts] {
                                    if {[lsearch -exact $binsOfInterest $bin_key] >= 0} {                                        
                                        set subSelectionDistances [expr $subSelectionDistances + [dict values $counts]]
                                    }                                    
                                }                                
                            }  
                        }           
                    }  
                }
                if {[expr $counter%100]==0} {
                    puts "$counter out of $atoms_sel1 atoms in selection 1 processed."
                }
                incr counter
            }
        } else {
            foreach atom_i $atom_numbers_sel1 {
                set atom_i_grp [dict get $atoms_groupNames $atom_i]
                set atom_i_grp [string range $atom_i_grp 1 [expr [string length $atom_i_grp] -2]]
                foreach atom_j $atom_numbers_sel2 {
                    if {$atom_i != $atom_j } {
                        set inSubSelection 0
                        set atom_j_grp [dict get $atoms_groupNames $atom_j]
                        set atom_j_grp [string range $atom_j_grp 1 [expr [string length $atom_j_grp] -2]]
                        set subgrp_pair "\[${atom_i_grp}:${atom_i}\] \[${atom_j_grp}:${atom_j}\]"
                        set subgrp_pair_reverse "\[${atom_j_grp}:${atom_j}\] \[${atom_i_grp}:${atom_i}\]"
                        set grp_pair "\[${atom_i_grp}\] \[${atom_j_grp}\]"
                        set grp_pair_reverse "\[${atom_j_grp}\] \[${atom_i_grp}\]"
                        if {(([lsearch -exact $atom_numbers_subSel1 $atom_i] >= 0 )&&([lsearch -exact $atom_numbers_subSel2 $atom_j] >= 0 )) || 
                            (([lsearch -exact $atom_numbers_subSel2 $atom_i] >= 0 )&&([lsearch -exact $atom_numbers_subSel1 $atom_j] >= 0 ))} {
                            set inSubSelection 1
                        }

                        set counts [dict create]
                        set hasCounts 0
                        if { [dict exists $subGroupPair_counts $subgrp_pair] ==1 } then {                       
                            set counts [dict get $subGroupPair_counts $subgrp_pair]     
                            set hasCounts 1
                        } elseif { [dict exists $subGroupPair_counts $subgrp_pair_reverse] ==1 } then {
                            set counts [dict get $subGroupPair_counts $subgrp_pair_reverse]         
                            set hasCounts 1
                        }

                        if {$hasCounts ==1} then {
                            if {$selection1!=$selection2} {
                                set selectionDistances [expr $selectionDistances + [ladd [dict values $counts]]]
                            } else {
                                set selectionDistances [expr $selectionDistances + [expr [ladd [dict values $counts]]/2]]
                                foreach key [dict keys $counts] {
                                    dict set counts $key [expr [dict get $counts $key]/2]
                                }
                            }
                            
                            if { [dict exists $selection_groups_counts $grp_pair] ==1 } then {
                                dict lappend selection_groups_counts $grp_pair $counts  
                            } elseif { [dict exists $selection_groups_counts $grp_pair_reverse] ==1 } then {    
                                dict lappend selection_groups_counts $grp_pair_reverse $counts
                            } else {
                                dict lappend selection_groups_counts $grp_pair $counts              
                            }

                            dict set selection_atom_contributions $atom_i 0
                            dict set selection_atom_contributions $atom_j 0     
                            
                            if { $inSubSelection } then {
                                if {$rbinRange=="all"} then {
                                    if { ($subselection1!=$subselection2) || ( ($subselection1=="all") && $selection1!=$selection2) } then {
                                        set subSelectionDistances [expr $subSelectionDistances + [ladd [dict values $counts]]]
                                    } else {
                                        set subSelectionDistances [expr $subSelectionDistances + [expr [ladd [dict values $counts]]/2]]
                                    }
                                    
                                } else {
                                    set binsOfInterest {}
                                    set binRanges [split $rbinRange ","]                                
                                    foreach binRange $binRanges {
                                        set binIndices [split $binRange "-"]
                                        if {[llength $binIndices]>1} then {
                                            set minSelectedR [expr int([expr [lindex $binIndices 0] / $delta])]
                                            set maxSelectedR [expr int([expr [lindex $binIndices 1] / $delta])]
                                            for {set b $minSelectedR} {$b <= $maxSelectedR} {incr b} {                                        
                                                lappend binsOfInterest $b
                                            }
                                        } else {
                                            lappend binsOfInterest [expr int([expr $binIndices / $delta])]
                                        }
                                    }
                                    
                                    foreach bin_key [dict keys $counts] {
                                        if {[lsearch -exact $binsOfInterest $bin_key] >= 0} {                                        
                                            if { ($subselection1!=$subselection2) || ( ($subselection1=="all") && $selection1!=$selection2) } then {
                                                set subSelectionDistances [expr $subSelectionDistances + [dict values $counts]]
                                            } else {
                                                set subSelectionDistances [expr $subSelectionDistances + [expr [dict get $counts $bin_key]/2]]
                                            }
                                        }                                    
                                    }                                
                                }  
                            }           
                        }               
                    }
                }

                if {[expr $counter%100]==0} {
                    puts "$counter out of $atoms_sel1 atoms in selection 1 processed."
                }
                incr counter
            }
        }
        
        printdistanceCounts $selectionDistances $subSelectionDistances $all_distances_count
        puts "Calculating atom and neighbor contributions from selections..."
        ### Read the contributions file and create the selection_atom_contributions for ranking, by filtering only the atoms from the selections
        set neighbour_contributions_file $input_file_path
        set write_to_file 0
        if {$useNonFFSq} then {
            append neighbour_contributions_file "neighbour_contributions_sq.dat"    
        } else {
            append neighbour_contributions_file "neighbour_contributions_ff_sq.dat"
        }
        set contributionsFile [open $neighbour_contributions_file r]
        set linesCnt 0
        set num_atoms_in_selection [llength [dict keys $selection_atom_contributions]]
        set isValid 0

        while { [gets $contributionsFile line] >= 0 } {            
            set startIdx 0
            set isValid 0
            set curIdx [string first "\{" $line $startIdx]        
            if {$curIdx > 0} {
                set atom_key [string trim [string range $line 0 [expr $curIdx-1]]]
                set neighbour_total_contribution {}
                set startIdx [expr $curIdx +1]
                set curIdx [string first "\{" $line $startIdx ]
                while {$curIdx > 0} {
                    set neighbour_key [string trim [string range $line $startIdx [expr $curIdx-1]]]
                    set curEndIdx [string first "\}" $line [expr $curIdx+1] ]
                    if {(([lsearch -exact $atom_numbers_sel1 $atom_key] >= 0 )&&([lsearch -exact $atom_numbers_sel2 $neighbour_key] >= 0 )) || 
                        (([lsearch -exact $atom_numbers_sel2 $atom_key] >= 0 )&&([lsearch -exact $atom_numbers_sel1 $neighbour_key] >= 0 ))} {                            
                        set isValid 1
                        set startIdx [expr $curIdx +1]
                        set neighbour_Sq [split [string trim [string range $line $startIdx [expr $curEndIdx-1]]] " "]
                        if {[llength $neighbour_total_contribution]>0} then {
                            for {set Sq_idx 0} {$Sq_idx < [llength $neighbour_total_contribution]} {incr Sq_idx} {
                                if { [catch {lset neighbour_total_contribution $Sq_idx [expr [lindex $neighbour_Sq $Sq_idx] + [lindex $neighbour_total_contribution $Sq_idx] ] } fid] } {
                                    puts "Could not add the 2 vectors: $neighbour_Sq ; $neighbour_total_contribution"
                                    exit 1
                                }
                            }
                        } else {
                            set neighbour_total_contribution $neighbour_Sq
                        }
                    }
                    set startIdx [expr $curEndIdx + 1]
                    set curIdx [string first "\{" $line $startIdx] 
                }
                if {$isValid==1} then {
                    dict set selection_atom_contributions $atom_key [list $neighbour_total_contribution {} {}]
                }
                
                # if {[lsearch -exact $required_atoms $atom_key] >= 0} { 
                #     set neighbour_total_contribution {}
                #     set startIdx [expr $curIdx +1]
                #     set curIdx [string first "\{" $line $startIdx ]             
                #     while {$curIdx > 0} {
                #         set neighbour_key [string trim [string range $line $startIdx [expr $curIdx-1]]]
                #         set curEndIdx [string first "\}" $line [expr $curIdx+1] ]  
                #         if {[lsearch -exact $required_atoms $neighbour_key] >= 0} { 
                #             set startIdx [expr $curIdx +1]
                #             set neighbour_Sq [split [string trim [string range $line $startIdx [expr $curEndIdx-1]]] " "]
                #             if {[llength $neighbour_total_contribution]>0} then {
                #                 for {set Sq_idx 0} {$Sq_idx < [llength $neighbour_total_contribution]} {incr Sq_idx} {
                #                     if { [catch {lset neighbour_total_contribution $Sq_idx [expr [lindex $neighbour_Sq $Sq_idx] + [lindex $neighbour_total_contribution $Sq_idx] ] } fid] } {
                #                         puts "Could add the 2 vectors: $neighbour_Sq ; $neighbour_total_contribution"
                #                         exit 1
                #                     }
                #                     # lset neighbour_total_contribution $Sq_idx [expr [lindex $neighbour_Sq $Sq_idx] + [lindex $neighbour_total_contribution $Sq_idx] ] 
                #                 }
                #             } else {
                #                 set neighbour_total_contribution $neighbour_Sq
                #             }
                #         }
                #         set startIdx [expr $curEndIdx + 1]
                #         set curIdx [string first "\{" $line $startIdx]                    
                #     }
                #     dict set selection_atom_contributions $atom_key [list $neighbour_total_contribution {} {}]
                # }
            }
        }
        close $contributionsFile        
        
        foreach grp_pair [dict keys $selection_groups_counts] {

            set cur_grp_pair_counts_list [dict get $selection_groups_counts $grp_pair]
            set cur_grp_pair_counts_dict [dict create]
            # Aggregate the counts in each group by bin numbers
            foreach item $cur_grp_pair_counts_list {
                foreach key [dict keys $item] {
                    set total_distances_count [expr [dict get $item $key] + $total_distances_count ]
                    set grps [split $grp_pair " "]                
                    set count_to_add [dict get $item $key]
                    if {[dict exists $cur_grp_pair_counts_dict $key]} then {
                        dict set cur_grp_pair_counts_dict $key [expr [dict get $cur_grp_pair_counts_dict $key] + $count_to_add]
                    } else {
                        dict set cur_grp_pair_counts_dict $key $count_to_add
                    }
                }
            }

            dict set selection_groups_counts $grp_pair $cur_grp_pair_counts_dict

            # calculate the sum of counts in each element group pair
            set cur_grp_pair_counts_sum 0
            foreach grp_bin [dict keys $cur_grp_pair_counts_dict] {
                set cur_grp_pair_counts_sum [expr $cur_grp_pair_counts_sum + [dict get $cur_grp_pair_counts_dict $grp_bin]]
            }

            # Get the weight of the current element group pair
            set pair_weight [expr double($cur_grp_pair_counts_sum) / $total_distances_count]
            dict set selection_groups_weights $grp_pair $pair_weight
            dict set selection_groups_weights_all_denominator $grp_pair [expr double($cur_grp_pair_counts_sum) / $all_distances_count]

            set grps [split $grp_pair " "]
            if {[lindex $grps 0]==[lindex $grps 1]} {
                lappend selection_groups_same_elements_weights $pair_weight
                set cur_pair_formfactor [dict get $groupPair_formfactors $grp_pair]
                set cur_pair_formfactor_list [split [lindex $cur_pair_formfactor 0] " "]
                lappend same_group_pair_formfactors $cur_pair_formfactor_list
            }
        }        
        puts "Done calculating atom and neighbor contributions from selections"

        computePartialsForSelections $selection_groups_counts $selection_groups_weights
        puts "Completed!"
        #testBinSummands $all_distances_count

    }

    set enableStatistics 1
    set enableRankings 1
    EnDisable
    $w.foot configure -state disabled

    set minval $min_q
    set maxval $max_q
    set tick_interval $delta_q

    $w.in2.topNframe.at configure -from 1 -to $num_atoms_in_selection -resolution 1 -tickinterval [expr $num_atoms_in_selection-1] -showvalue true
    $w.in2.topNframe.bt configure -from 0 -to $num_atoms -resolution 1 -tickinterval [expr $num_atoms-1] -showvalue true
    $w.in1.at configure -from $minval -to $maxval -resolution $tick_interval  -tickinterval [expr $maxval-$minval] -showvalue true
    $w.in1.bt configure -from $minval -to $maxval -resolution $tick_interval  -tickinterval [expr $maxval-$minval] -showvalue true
    update idletasks
}

proc ::SQGUI::DisplayStatsForSelections {} {

    global group_pair_s_q
    global ff_weighted_group_pair_s_q
    global rbin_contributions_for_total_S_q
    global rbin_contributions_for_ff_weighted_S_q
    global selection_S_q_pos_contributions
    global selection_S_q_neg_contributions  
    global selection_weighted_S_q_pos_contributions
    global selection_weighted_S_q_neg_contributions
    global selection_atoms_counts
    global topN_Sorted
    global selection_atom_contributions
    global rank_plot
    global atoms_groupNames
    global group_formfactors
    global atom_numbers_sel1
    global atom_numbers_sel2

    variable displayAtoms
    variable addBeta
    variable molid
    variable w
    variable cannotplot
    variable delta
    variable rmax
    variable min_q
    variable max_q
    variable delta_q
    variable leftBin
    variable rightBin  
    variable topN
    variable atom_beta_by_Score
    variable atom_beta_by_Rank_Sorted
    variable atom_beta_by_Score_Sorted
    variable display_FormFactorWeighted_Results

    variable selection1
    variable selection2
    variable subselection1
    variable subselection2

    set s_q_rbin_contributions_selected_range {}
    set ff_s_q_rbin_contributions_selected_range {}
    set y_bins {}
    set x_bins {}
    set bins_plot  "";

    set q_idx 0
    set s_q_val_selected_range 0
    set s_q_pos_val_selected_range 0
    set s_q_neg_val_selected_range 0
    set s_q_pos_neg_val_selected_range 0
    set ff_s_q_val_selected_range 0
    set ff_s_q_pos_val_selected_range 0
    set ff_s_q_neg_val_selected_range 0
    set ff_s_q_pos_neg_val_selected_range 0
    set topN_list {}
    set rbin_x {}
    set atom_beta_by_Rank {};
    set atom_beta_by_Score {};
    
    set numbins [expr $rmax / $delta]

    set sel1_20 [string range $selection1 0 20]
    set sel2_20 [string range $selection2 0 20]
    set subsel1_20 [string range $subselection1 0 20]
    set subsel2_20 [string range $subselection2 0 20]
    set adjusted_rightBin [expr $rightBin + [expr $delta_q/100]]
    set adjusted_leftBin [expr $leftBin - [expr $delta_q/100]]
    for {set cur_q $min_q} {$cur_q <= $adjusted_rightBin} {set cur_q [expr {$cur_q + $delta_q}]} {
        if {$cur_q >= $adjusted_leftBin} {
            set s_q_val_selected_range [expr $s_q_val_selected_range + [lindex $group_pair_s_q $q_idx]]  
            foreach key [dict keys $ff_weighted_group_pair_s_q] {
                set ff_s_q_values [dict get $ff_weighted_group_pair_s_q $key]                
                set ff_s_q_val_selected_range [expr $ff_s_q_val_selected_range + [lindex $ff_s_q_values $q_idx]]            
            }

            if {[llength $s_q_rbin_contributions_selected_range]==0} then {
                set s_q_rbin_contributions_selected_range [lindex $rbin_contributions_for_total_S_q $q_idx]
            } else {
                set rbins_for_q_new [lindex $rbin_contributions_for_total_S_q $q_idx]
                for {set q 0} {$q < [llength $s_q_rbin_contributions_selected_range]} {incr q} {
                    lset s_q_rbin_contributions_selected_range $q [expr [lindex $s_q_rbin_contributions_selected_range $q] + [lindex $rbins_for_q_new $q]]
                }
            }

            set s_q_pos_values [dict get $selection_S_q_pos_contributions $cur_q]
            set s_q_neg_values [dict get $selection_S_q_neg_contributions $cur_q]
            set s_q_pos_val_selected_range [expr $s_q_pos_val_selected_range + $s_q_pos_values]
            set s_q_neg_val_selected_range [expr $s_q_neg_val_selected_range + $s_q_neg_values]
           
            if {[llength $ff_s_q_rbin_contributions_selected_range]==0} then {
                set ff_s_q_rbin_contributions_selected_range [lindex $rbin_contributions_for_ff_weighted_S_q $q_idx]
            } else {
                set rbins_for_q_new [lindex $rbin_contributions_for_ff_weighted_S_q $q_idx]
                for {set q 0} {$q < [llength $ff_s_q_rbin_contributions_selected_range]} {incr q} {
                    lset ff_s_q_rbin_contributions_selected_range $q [expr [lindex $ff_s_q_rbin_contributions_selected_range $q] + [lindex $rbins_for_q_new $q]]
                }
            }
            
            set ff_s_q_pos_values [dict get $selection_weighted_S_q_pos_contributions $cur_q]
            set ff_s_q_neg_values [dict get $selection_weighted_S_q_neg_contributions $cur_q]

            set ff_s_q_pos_val_selected_range [expr $ff_s_q_pos_val_selected_range + $ff_s_q_pos_values]
            set ff_s_q_neg_val_selected_range [expr $ff_s_q_neg_val_selected_range + $ff_s_q_neg_values]
        }
        incr q_idx
    }
    
    set start_r 0
    for {set i 0} {$i < $numbins} {incr i} {
        lappend rbin_x $start_r
        set start_r [expr $start_r + $delta]
    }

    if {$cannotplot} then {
        tk_dialog .errmsg {viewSq Error} "Multiplot is not available." error 0 Dismiss
    } else { 
        # plot rbin contributions to s(q) for the selected q range
        set selection_rbins_plot [multiplot -x $rbin_x -y $s_q_rbin_contributions_selected_range -title "Selections - contributions to S(q) and Form factor weighted S(q) plot ($sel1_20-$sel2_20)" \
                                                -legend "S(q)" -nolines -fillcolor red -linecolor red -marker point -radius 2 -plot]

        # plot rbin contributions to form factor weighted s(q) for the selected q range
        $selection_rbins_plot add $rbin_x $ff_s_q_rbin_contributions_selected_range -nolines -fillcolor blue -legend "Form factor weighted S(q)- Full denominator" -marker square -radius 2 -plot
    } 

    set s_q_pos_neg_val_selected_range [expr $s_q_pos_val_selected_range + abs($s_q_neg_val_selected_range)]
    set s_q_val_selected_range [expr {double(round(100000*$s_q_val_selected_range))/100000}]
    set s_q_pos_val_selected_range [expr {double(round(100000*$s_q_pos_val_selected_range))/100000}]
    set s_q_neg_val_selected_range [expr {double(round(100000*$s_q_neg_val_selected_range))/100000}]
    set s_q_pos_neg_val_selected_range [expr {double(round(100000*$s_q_pos_neg_val_selected_range))/100000}]

    set ff_s_q_pos_neg_val_selected_range [expr $ff_s_q_pos_val_selected_range + abs($ff_s_q_neg_val_selected_range)]
    set ff_s_q_val_selected_range [expr {double(round(100000*$ff_s_q_val_selected_range))/100000}]
    set ff_s_q_pos_val_selected_range [expr {double(round(100000*$ff_s_q_pos_val_selected_range))/100000}]
    set ff_s_q_neg_val_selected_range [expr {double(round(100000*$ff_s_q_neg_val_selected_range))/100000}]
    set ff_s_q_pos_neg_val_selected_range [expr {double(round(100000*$ff_s_q_pos_neg_val_selected_range))/100000}]
    
    wm title . "Results for Selections" 
    ## destroy the window if already exists. 
    if {[catch { destroy .gui } ]} then {puts "window destroyed!!"}
    ## Make a unique widget name
    set selection_results .gui

    ## Make the toplevel
    toplevel $selection_results
    wm title $selection_results "Results for Selections"
    wm minsize $selection_results 700 160

    labelframe $selection_results.in -bd 2 -relief ridge -text "Selections:" -padx 1m -pady 1m
    button $selection_results.ok  -text {OK} -command [list destroy $selection_results]
    grid $selection_results.in   -row 0 -column 0 -sticky snew
    grid $selection_results.ok   -row 1 -column 0 -sticky sew

    grid columnconfigure $selection_results 0 -minsize 700 -weight 1
    grid rowconfigure    $selection_results 0 -weight 10   -minsize 135
    grid rowconfigure    $selection_results 1 -weight 1    -minsize 25
    
    set cur_UI $selection_results.in
    set l0 [label $cur_UI.lable_Sq1 -text "          " -justify right -font {helvetica 12 bold}]
    set l1 [label $cur_UI.lable_Sq2 -text "S(q)" -justify right -font {helvetica 12 bold}]

    set l2 [label $cur_UI.lable_Sq3 -text "Form Factor Weighted S(q)- Full denominator" -justify left -font {helvetica 12 bold}]
    grid $l0 $l1 $l2 
    grid $l0 $l1 

    set l3 [label $cur_UI.lable_Sq -text "S(q): " -justify right -font {helvetica 12 bold}]
    set l4 [label $cur_UI.lable_Sq_val1 -text $s_q_val_selected_range -justify left -font {helvetica 12 bold}]
    set l5 [label $cur_UI.lable_Sq_val2 -text $ff_s_q_val_selected_range -justify left -font {helvetica 12 bold}]
    grid $l3 $l4 $l5
    grid $l3 $l4 

    set l6 [label $cur_UI.lable_Sq_pos -text "Positive contribution: " -justify right -font {helvetica 12 bold}]
    set l7 [label $cur_UI.lable_Sq_pos_val1 -text $s_q_pos_val_selected_range -justify left -font {helvetica 12 bold}]
    set l8 [label $cur_UI.lable_Sq_pos_val2 -text $ff_s_q_pos_val_selected_range -justify left -font {helvetica 12 bold}]
    grid $l6 $l7 $l8
    grid $l6 $l7

    set l9 [label $cur_UI.lable_Sq_neg -text "Negative contribution: " -justify right -font {helvetica 12 bold}]
    set l10 [label $cur_UI.lable_Sq_neg_val1 -text $s_q_neg_val_selected_range -justify left -font {helvetica 12 bold}]
    set l11 [label $cur_UI.lable_Sq_neg_val2 -text $ff_s_q_neg_val_selected_range -justify left -font {helvetica 12 bold}]
    grid $l9 $l10 $l11
    grid $l9 $l10
    
    set l12 [label $cur_UI.lable_Sq_pos_neg -text "Positive + magnitude of negative contribution: " -justify right -font {helvetica 12 bold}]
    set l13 [label $cur_UI.lable_Sq_pos_neg_val1 -text $s_q_pos_neg_val_selected_range -justify left -font {helvetica 12 bold}]
    set l14 [label $cur_UI.lable_Sq_pos_neg_val2 -text $ff_s_q_pos_neg_val_selected_range -justify left -font {helvetica 12 bold}]
    grid $l12 $l13 $l14 
    grid $l12 $l13

    foreach key [dict keys $selection_atom_contributions] {
        set key_group [dict get $atoms_groupNames $key]
        set key_ff [dict get $group_formfactors $key_group]
        
        set s_q_contributions [lindex [dict get $selection_atom_contributions $key] 0]
        set s_q_for_selection 0
        set q_idx 0
        
        if {[llength $s_q_contributions]>0} then {
            for {set cur_q $min_q} {$cur_q <= $adjusted_rightBin} {set cur_q [expr {$cur_q + $delta_q}]} {
                if {$cur_q >= $adjusted_leftBin} {
                    set s_q_for_selection [expr $s_q_for_selection + [lindex $s_q_contributions $q_idx] ]
                }
                incr q_idx
            }
        }
        lappend topN_list [list $key $s_q_for_selection $key_group]
    }

    set topN_Sorted [lsort -real -index 1 -decreasing $topN_list]    
    set cntr 0
    set sorted_atoms "serial "
    set atom_properties {}
    foreach {pair} $topN_Sorted {        
        incr cntr
        lappend x_bins $cntr
        lappend y_bins [lindex $pair 1]
        append sorted_atoms "[lindex $pair 0] "
        lappend atom_beta_by_Rank [list [lindex $pair 0] $cntr]
        lappend atom_beta_by_Score [list [lindex $pair 0] [lindex $pair 1]]
        set tmpsel [atomselect $molid "serial [lindex $pair 0]"]
        set cur_atom_props "[lindex $pair 2] "
        append cur_atom_props [join [$tmpsel get {type name serial residue resname resid chain}] " "]        
        set cur_atom_props [join $cur_atom_props " "]
        set sel1_presence "no"
        set sel2_presence "no"
        if {[lsearch -exact $atom_numbers_sel1 [lindex $pair 0]] >= 0} {
            set sel1_presence "yes"
        }
        if {[lsearch -exact $atom_numbers_sel2 [lindex $pair 0]] >= 0} {
            set sel2_presence "yes"
        }
        append cur_atom_props " $sel1_presence $sel2_presence"
        lappend atom_properties "\"$cur_atom_props\""   
    }

    set atom_beta_by_Rank [lsort -real -index 0 $atom_beta_by_Rank]    
    set atom_beta_by_Score [lsort -real -index 0 $atom_beta_by_Score]   
    set atom_beta_by_Rank_Sorted {}
    set atom_beta_by_Score_Sorted {}
    for {set i_beta 0} {$i_beta < [llength $atom_beta_by_Rank]} {incr i_beta} {
         lappend atom_beta_by_Rank_Sorted [lindex [lindex $atom_beta_by_Rank $i_beta] 1]
         lappend atom_beta_by_Score_Sorted [lindex [lindex $atom_beta_by_Score $i_beta] 1]
     } 
    if {[catch {$bins_plot quit} ]} then {}
    set rank_plot [multiplot -x $x_bins -y $y_bins -title "Top Contributors" -lines -linewidth 2 -marker point -plot ]  
    $rank_plot add $x_bins $atom_properties

    if {$displayAtoms} {
        set sel_all [atomselect $molid $sorted_atoms ]       
        if {$addBeta} {
            #atoms by rank
            $sel_all set beta 0
            $sel_all set beta $atom_beta_by_Rank_Sorted
        } else {
            #atoms by score
            $sel_all set beta 0
            $sel_all set beta $atom_beta_by_Score_Sorted
        }
    }
    $w.in2.topNframe.at configure -command [namespace code UpdateRenderer]
    $w.in2.topNframe.bt configure -command [namespace code UpdateRenderer]
}

proc ::SQGUI::UpdateRenderer {val} {
    
    global topN_Sorted
    global rank_plot
    global selection_atom_contributions
    global atoms_groupNames
    global group_formfactors

    variable w
    variable molid
    variable displayAtoms
    variable addBeta
    variable input_file_path
    variable min_q
    variable max_q
    variable delta_q
    variable leftBin
    variable rightBin 
    variable useNonFFSq

    variable vis_selection1
    variable selection1_colorId
    variable selection1_color_method
    variable selection1_material
    variable selection1_draw_method
    variable vis_selection2
    variable selection2_colorId
    variable selection2_color_method
    variable selection2_material
    variable selection2_draw_method
    variable vis_selection3
    variable selection3_colorId
    variable selection3_color_method
    variable selection3_material
    variable selection3_draw_method
    variable vis_selection4
    variable selection4_colorId
    variable selection4_color_method
    variable selection4_material
    variable selection4_draw_method
    variable vis_selection5
    variable selection5_colorId
    variable selection5_color_method
    variable selection5_material
    variable selection5_draw_method
    variable atom_beta_by_Rank_Sorted
    variable atom_beta_by_Score_Sorted
    variable atom_beta_by_Score
    variable molecule_beta_by_Rank
    variable molecule_beta_by_Score

    set selected_atoms "serial"
    set selected_atom [$w.in2.topNframe.bt get]
    set selected_topnN [$w.in2.topNframe.at get]
    set molecule_beta_by_Rank {}
    set molecule_beta_by_Score {}
    set molecule_beta_by_Rank_Sorted {}
    set molecule_beta_by_Score_Sorted {}
    set neighbor_beta_by_Score {}
    set neighbor_beta_by_Rank {}
    set x_bins {}
    set y_bins {}

    display update off
    color scale method BWR
    display update on
    for {set i 0} {$i < 7} {incr i} {
        mol delrep 0 top
    }
    if {$selected_atom == 0} {
        set sorted_atoms "serial "
        foreach {pair} $topN_Sorted {     
            append sorted_atoms "[lindex $pair 0] "    
        }
        foreach {pair} [lrange $topN_Sorted 0 [expr $selected_topnN -1]] {     
            set selected_atoms [concat $selected_atoms " " [lindex $pair 0]]                                
        }
        
        if {$displayAtoms} then { 
            set sel1Str $selected_atoms
            set sel2Str $selected_atoms
            set sel3Str $selected_atoms
            set sel4Str $selected_atoms
            set sel5Str $selected_atoms

        } else {
            
            set sel1Str "same resid as ( $selected_atoms )"
            set sel2Str "same resid as ( $selected_atoms )"
            set sel3Str "same resid as ( $selected_atoms )"
            set sel4Str "same resid as ( $selected_atoms )"
            set sel5Str "same resid as ( $selected_atoms )"
        }               
    } else {
        set neighbour_contributions_file $input_file_path   
        if {$useNonFFSq} then {
            append neighbour_contributions_file "neighbour_contributions_sq.dat"    
        } else {
            append neighbour_contributions_file "neighbour_contributions_ff_sq.dat"
        }         
        set tstfile [open $neighbour_contributions_file r]
        set topN_list {}
        set required_atoms [dict keys $selection_atom_contributions]
        while { [gets $tstfile line] >= 0 } {
            set startIdx 0
            set curIdx [string first "\{" $line $startIdx]        
            if {$curIdx > 0} {
                set atom_key [string trim [string range $line 0 [expr $curIdx-1]] "\{\} " ]
                if {$atom_key == $selected_atom} { 
                    incr readLinesCnt
                    set neighbour_total_contribution {}
                    set startIdx [expr $curIdx +1]
                    set curIdx [string first "\{" $line $startIdx ]             
                    while {$curIdx > 0} {
                        set neighbour_key [string trim [string range $line $startIdx [expr $curIdx-1]] "\{\} " ]                        
                        set curEndIdx [string first "\}" $line [expr $curIdx+1] ]  
                        if {[lsearch -exact $required_atoms $neighbour_key] >= 0} { 
                            set startIdx [expr $curIdx +1]
                            set neighbour_Sq [split [string trim [string range $line $startIdx [expr $curEndIdx-1]] "\{\} " ] " "]

                            set s_q_for_selection 0
                            set q_idx 0
                            for {set cur_q $min_q} {$cur_q <= $rightBin} {set cur_q [expr {$cur_q + $delta_q}]} {
                                if {$cur_q >= $leftBin} {
                                    set s_q_for_selection [expr $s_q_for_selection + [lindex $neighbour_Sq $q_idx]]  
                                }
                                incr q_idx
                            }
                            set key_group [dict get $atoms_groupNames $neighbour_key]
                            set key_ff [dict get $group_formfactors $key_group]
                            lappend topN_list [list $neighbour_key $s_q_for_selection $key_group]
                        }
                        set startIdx [expr $curEndIdx + 1]
                        set curIdx [string first "\{" $line $startIdx]                    
                    }
                    break                
                }
            }              
        }
        close $tstfile

        set topN_Neighbours_Sorted [lsort -real -index 1 -decreasing $topN_list]
        set cntr 0
        set sorted_atoms "serial "
        set atom_properties {}

        foreach {pair} $topN_Neighbours_Sorted {
            incr cntr
            lappend x_bins $cntr
            lappend y_bins [lindex $pair 1]
            append sorted_atoms "[lindex $pair 0] "
            lappend neighbor_beta_by_Rank [list [lindex $pair 0] $cntr]
            lappend neighbor_beta_by_Score [list [lindex $pair 0] [lindex $pair 1]]

            set tmpsel [atomselect $molid "serial [lindex $pair 0]"]
            set cur_atom_props "[lindex $pair 2],"
            append cur_atom_props [join [$tmpsel get {type name residue resname resid chain}] ","]
            set cur_atom_props [join $cur_atom_props ","]
            lappend atom_properties "$cur_atom_props"           
        }  

        set neighbor_beta_by_Rank [lsort -real -index 0 $neighbor_beta_by_Rank]    
        set neighbor_beta_by_Score [lsort -real -index 0 $neighbor_beta_by_Score]   
        set neighbor_beta_by_Rank_Sorted {}
        set neighbor_beta_by_Score_Sorted {}
        for {set i_beta 0} {$i_beta < [llength $neighbor_beta_by_Rank]} {incr i_beta} {
             lappend neighbor_beta_by_Rank_Sorted [lindex [lindex $neighbor_beta_by_Rank $i_beta] 1]
             lappend neighbor_beta_by_Score_Sorted [lindex [lindex $neighbor_beta_by_Score $i_beta] 1]
         } 

        if {[catch {$rank_plot quit} ]} then {}
        set rank_plot [multiplot -x $x_bins -y $y_bins -title "Top Neighbors" -lines -linewidth 2 -marker point -plot ]   
        $rank_plot add $x_bins $atom_properties       

        foreach {pair} [lrange $topN_Neighbours_Sorted 0 [expr $selected_topnN -1]] {     
            set selected_atoms [concat $selected_atoms " " [lindex $pair 0]]
        }
        
        if {$displayAtoms} then { 
            set sel1Str $selected_atoms
            set sel2Str $selected_atoms
            set sel3Str $selected_atoms
            set sel4Str $selected_atoms
            set sel5Str $selected_atoms
        } else {
            
            set sel1Str "same resid as ( $selected_atoms )"
            set sel2Str "same resid as ( $selected_atoms )"
            set sel3Str "same resid as ( $selected_atoms )"
            set sel4Str "same resid as ( $selected_atoms )"
            set sel5Str "same resid as ( $selected_atoms )"
        }    
    }  

    if {$displayAtoms} {
        set sel_all [atomselect $molid $sorted_atoms ]        
        if {$addBeta} {
            #atoms by rank
            $sel_all set beta 0
            if {$selected_atom == 0} {
                $sel_all set beta $atom_beta_by_Rank_Sorted
            } else {
                $sel_all set beta $neighbor_beta_by_Rank_Sorted
            }
        } else {
            #atoms by score
            $sel_all set beta 0

            if {$selected_atom == 0} {
                $sel_all set beta $atom_beta_by_Score_Sorted
            } else {
                $sel_all set beta $neighbor_beta_by_Score_Sorted
            }
        }
    } else {
        
        set all_atoms_test [atomselect $molid "all"]
        $all_atoms_test set beta 0
        set all_molecules [$all_atoms_test get {serial resid}]

        set sel_atoms [atomselect $molid $selected_atoms ]        
        set selected_molecules [ $sel_atoms get {serial resid}]
        set molecules_count [dict create]
        set molecules_score [dict create]

        if {$addBeta} {
            #molecules by rank
            foreach var $selected_molecules {
                if {[dict exists $molecules_count [lindex $var 1]]} then {
                    dict set molecules_count [lindex $var 1] [expr [dict get $molecules_count [lindex $var 1]] + 1]
                } else {
                    dict set molecules_count [lindex $var 1] 1
                }
            }
            foreach var $all_molecules {
                if {[dict exists $molecules_count [lindex $var 1]]} then {
                    lappend molecule_beta_by_Rank [dict get $molecules_count [lindex $var 1]]
                } else {
                    lappend molecule_beta_by_Rank 0
                }            
            }

            $all_atoms_test set beta $molecule_beta_by_Rank
        } else {
            #molecules by score
            set idx 0
            foreach var $selected_molecules {
                set tmp_score 0
                if {$selected_atom == 0} {
                    set tmp_score [lindex $atom_beta_by_Score_Sorted [lindex $var 0]]
                } else {
                    set tmp_score [lindex $y_bins $idx]
                }
                if {[dict exists $molecules_score $var]} then {
                    dict set molecules_score [lindex $var 1] [expr [dict get $molecules_score [lindex $var 1]] + $tmp_score]
                } else {
                    dict set molecules_score [lindex $var 1] $tmp_score
                }
                incr idx
            }
            foreach var $all_molecules {
                if {[dict exists $molecules_score [lindex $var 1]]} then {
                    lappend molecule_beta_by_Score [dict get $molecules_score [lindex $var 1]]
                } else {
                    lappend molecule_beta_by_Score 0
                } 
            }

            puts "rank - $molecule_beta_by_Score"
            $all_atoms_test set beta $molecule_beta_by_Score
        }
    } 

    if {$vis_selection1 != ""} {            
        append sel1Str " and $vis_selection1"
        set sel1 [atomselect $molid $sel1Str ] 
        mol selection "[$sel1 text]" 
        if {$selection1_color_method=="ColorID"} then {
            mol color ColorID $selection1_colorId
        } else {
            mol color $selection1_color_method
        }
        mol material $selection1_material                
        mol representation $selection1_draw_method
        mol addrep top
    }
    if {$vis_selection2 != ""} {
        append sel2Str " and $vis_selection2"
        set sel2 [atomselect $molid $sel2Str ] 
        mol selection "[$sel2 text]" 
        if {$selection2_color_method=="ColorID"} then {
            mol color ColorID $selection2_colorId
        } else {
            mol color $selection2_color_method
        }
        mol material $selection2_material                
        mol representation $selection2_draw_method
        mol addrep top
    }
    if {$vis_selection3 != ""} {
        append sel3Str " and $vis_selection3"
        set sel3 [atomselect $molid $sel3Str ] 
        mol selection "[$sel3 text]" 
        if {$selection3_color_method=="ColorID"} then {
            mol color ColorID $selection3_colorId
        } else {
            mol color $selection3_color_method
        }
        mol material $selection3_material                
        mol representation $selection3_draw_method
        mol addrep top
    }
    if {$vis_selection4 != ""} {
        append sel4Str " and $vis_selection4"
        set sel4 [atomselect $molid $sel4Str ] 
        mol selection "[$sel4 text]" 
        if {$selection4_color_method=="ColorID"} then {
            mol color ColorID $selection4_colorId
        } else {
            mol color $selection4_color_method
        }
        mol material $selection4_material                
        mol representation $selection4_draw_method
        mol addrep top
    }
    if {$vis_selection5 != ""} {
        append sel1Str " and $vis_selection5"
        set sel5 [atomselect $molid $sel1Str ] 
        mol selection "[$sel5 text]" 
        if {$selection5_color_method=="ColorID"} then {
            mol color ColorID $selection5_colorId
        } else {
            mol color $selection5_color_method
        }
        mol material $selection5_material                
        mol representation $selection5_draw_method
        mol addrep top
    } 

    if {$selected_atom != 0} {
        set chosenAtom "serial $selected_atom"
        set atom_sel [atomselect $molid $chosenAtom]  
        mol selection "[$atom_sel text]" 
        mol color ColorID 8
        mol representation VDW
        mol addrep top 
    }
}

#################
# build GUI.
proc ::SQGUI::sqgui {args} {    

    variable w
    variable molid

    variable selection1_color_method
    variable selection2_color_method
    variable selection3_color_method
    variable selection4_color_method
    variable selection5_color_method

    # main window frame
    set w .sqgui
    catch {destroy $w}
    toplevel    $w
    wm title    $w "viewSq" 
    wm iconname $w "SQUI" 
    wm minsize  $w 700 450 

    # top level dialog components
    # frame for settings
    labelframe $w.in -bd 2 -relief ridge -text "Settings:" -padx 1m -pady 1m
    # computation action button
    button $w.foot -text {Compute S(q)} -command [namespace code runSofQ]
    # frame for selections
    labelframe $w.sel -bd 2 -relief ridge -text "Selections:" -padx 1m -pady 1m
    # frame for q range
    labelframe $w.in1 -bd 2 -relief ridge -text "q Range Selection:" -padx 1m -pady 1m
    # frame for vis settings
    labelframe $w.in2 -bd 2 -relief ridge -text "Visualization Settings:" -padx 1m -pady 1m

    # layout main canvas
    grid $w.in      -row 0 -column 0 -sticky snew
    grid $w.foot    -row 1 -column 0 -sticky sew
    grid $w.sel    -row 2 -column 0 -sticky sew
    grid $w.in1    -row 3 -column 0 -sticky sew
    grid $w.in2    -row 4 -column 0 -sticky sew
    grid columnconfigure $w 0 -minsize 580 -weight 1
    grid rowconfigure    $w 0 -weight 10   -minsize 150
    grid rowconfigure    $w 1 -weight 1    -minsize 25
    grid rowconfigure    $w 2 -weight 1    -minsize 40
    grid rowconfigure    $w 3 -weight 1    -minsize 50
    grid rowconfigure    $w 4 -weight 1    -minsize 80

    # frame for g(r) settings
    labelframe $w.in.gr_settings -bd 2 -relief ridge -text "g(r) Settings:" -padx 1m -pady 1m
    # frame for s(q) settings
    labelframe $w.in.sq_settings -bd 2 -relief ridge -text "S(q) Settings:" -padx 1m -pady 1m
    
    #################
    # subdivide and layout the settings frame
    frame $w.in.molid
    grid $w.in.molid -row 0 -column 0 -sticky snew
    grid $w.in.gr_settings   -row 1 -column 0 -sticky snew
    grid $w.in.sq_settings   -row 2 -column 0 -sticky snew
    grid columnconfigure $w.in 0 -weight 1
    grid rowconfigure    $w.in 0 -weight 1 
    grid rowconfigure    $w.in 1 -weight 3
    grid rowconfigure    $w.in 2 -weight 1

    # Molecule selector
    set i $w.in.molid
    label $i.l -text "Molecule:" -anchor w
    menubutton $i.m -relief raised -bd 2 -direction flush \
    -text "test" -textvariable ::SQGUI::moltxt \
    -menu $i.m.menu
    menu $i.m.menu -tearoff no
    grid $i.l $i.m -sticky snew -row 0
    grid columnconfigure $i 0 -weight 1
    grid columnconfigure $i 1 -weight 10

    #################
    # subdivide and layout the g(r) settings frame
    set i $w.in.gr_settings
    labelframe $i.frms -bd 2 -relief ridge -text "Frames:" -padx 1m -pady 1m
    labelframe $i.histfrm -bd 2 -relief ridge -text "Histogram Parameters:" -padx 1m -pady 1m
    labelframe $i.fffrm -bd 2 -relief ridge -text "Form Factor Parameters:" -padx 1m -pady 1m
    label $i.temp1 -text "     " 
    label $i.temp2 -text "     " 
    label $i.temp3 -text "     "

    grid $i.temp1 $i.frms $i.temp2 $i.histfrm $i.temp3 $i.fffrm -row 0 -sticky snew    
    grid columnconfigure $i.temp1 0 -weight 2
    grid columnconfigure $i.frms 1  -weight 3
    grid columnconfigure $i.temp2 2 -weight 2
    grid columnconfigure $i.histfrm 3  -weight 3
    grid columnconfigure $i.temp3 4 -weight 2
    grid columnconfigure $i.fffrm 5  -weight 4

    # Frames range parameters
    frame $i.frms.params
    grid $i.frms.params -row 0 -column 0 -sticky snew
    
    set i $i.frms.params
    label $i.fl -text "First:" -anchor e
    entry $i.ft -width 10 -textvariable ::SQGUI::first
    label $i.ftemp -text "    " -anchor e
    label $i.ll -text "Last:" -anchor e
    entry $i.lt -width 10 -textvariable ::SQGUI::last
    label $i.ltemp -text "    " -anchor e
    label $i.sl -text "Step:" -anchor e
    entry $i.st -width 10 -textvariable ::SQGUI::step
    grid $i.fl -row 0 -column 0 -sticky snew
    grid $i.ft -row 0 -column 1 -sticky snew
    grid $i.ftemp -row 0 -column 2 -sticky snew
    grid $i.ll -row 0 -column 3 -sticky snew
    grid $i.lt -row 0 -column 4 -sticky snew
    grid $i.ltemp -row 0 -column 5 -sticky snew
    grid $i.sl -row 0 -column 6 -sticky snew
    grid $i.st -row 0 -column 7 -sticky snew

    grid columnconfigure $i 0 -weight 1
    grid columnconfigure $i 1 -weight 1
    grid columnconfigure $i 2 -weight 1
    grid columnconfigure $i 3 -weight 1
    grid columnconfigure $i 4 -weight 1
    grid columnconfigure $i 5 -weight 1
    grid columnconfigure $i 6 -weight 1
    grid columnconfigure $i 7 -weight 1
    grid rowconfigure    $i 0 -weight 1

    # Histogram parameters
    set i $w.in.gr_settings
    frame $i.histfrm.params
    grid $i.histfrm.params -row 0 -column 1 -sticky snew

    set i $i.histfrm.params
    label $i.deltal -text "Delta r \[Å\]:" -anchor e
    entry $i.deltat -width 10 -textvariable ::SQGUI::delta
    label $i.temp -text "    " -anchor e
    label $i.rmaxl -text "Max r \[Å\]:" -anchor e
    entry $i.rmaxt -width  10 -textvariable ::SQGUI::rmax
    grid $i.deltal -row 0 -column 0 -sticky snew
    grid $i.deltat -row 0 -column 1 -sticky snew
    grid $i.temp -row 0 -column 2 -sticky snew
    grid $i.rmaxl -row 0 -column 3 -sticky snew
    grid $i.rmaxt -row 0 -column 4 -sticky snew
    grid columnconfigure $i 0 -weight 2
    grid columnconfigure $i 1 -weight 2
    grid columnconfigure $i 2 -weight 1
    grid columnconfigure $i 3 -weight 2
    grid columnconfigure $i 4 -weight 2

    # Form factor constant parameters
    set i $w.in.gr_settings
    frame $i.fffrm.params
    grid $i.fffrm.params -row 0 -column 1 -sticky snew

    set i $i.fffrm.params
    label $i.useLbl -text "Use Constants:" -anchor e
    radiobutton $i.xray    -text "X-ray " -variable ::SQGUI::useXRay  -value "1"
    radiobutton $i.neutron -text "Neutron " -variable ::SQGUI::useXRay  -value "0"
    
    grid $i.useLbl -row 0 -column 0 -sticky snew
    grid $i.xray -row 0 -column 1 -sticky snew
    grid $i.neutron -row 0 -column 2 -sticky snew
    grid columnconfigure $i 0 -weight 3
    grid columnconfigure $i 1 -weight 2
    grid columnconfigure $i 2 -weight 2
    
    #################
    # subdivide and layout the S(q) settings frame
    set i $w.in.sq_settings
    label $i.minQ -text "Min q \[Å\u207B\u2071\]:" 
    entry $i.minQt -width 15 -textvariable ::SQGUI::min_q
    label $i.temp1 -text "  "
    label $i.maxQ -text "Max q \[Å\u207B\u2071\]:"
    entry $i.maxQt -width 15 -textvariable ::SQGUI::max_q
    label $i.temp2 -text "  "
    label $i.deltaQ -text "Delta q \[Å\u207B\u2071\]:"
    entry $i.deltaQt -width 15 -textvariable ::SQGUI::delta_q

    grid  $i.minQ $i.minQt $i.temp1 $i.maxQ $i.maxQt $i.temp2 $i.deltaQ $i.deltaQt  -row 0 -sticky snew
    grid columnconfigure $i 0 -weight 2
    grid columnconfigure $i 1 -weight 2
    grid columnconfigure $i 2 -weight 1
    grid columnconfigure $i 3 -weight 2
    grid columnconfigure $i 4 -weight 2
    grid columnconfigure $i 5 -weight 1
    grid columnconfigure $i 6 -weight 2
    grid columnconfigure $i 7 -weight 2

    #################
    # subdivide and layout the Selections frame
    set i $w.sel
    label $i.al -text "Selection 1:" 
    entry $i.at -width 20 -textvariable ::SQGUI::selection1
    label $i.temp -text "  "
    label $i.bl -text "Selection 2:"
    entry $i.bt -width 20 -textvariable ::SQGUI::selection2
    label $i.al1 -text "Subselection 1:" 
    entry $i.at1 -width 20 -textvariable ::SQGUI::subselection1
    label $i.temp2 -text "  "
    label $i.bl1 -text "Subselection 2:"
    entry $i.bt1 -width 20 -textvariable ::SQGUI::subselection2
    label $i.cl1 -text "r-bin(s):"
    entry $i.ct1 -width 20 -textvariable ::SQGUI::rbinRange
    label $i.temp3 -text "  "
    # label $i.temp4 -text "  "

    label $i.al2 -text ""
    radiobutton $i.usenonFF    -text "No Form Factor" -variable ::SQGUI::useNonFFSq  -value "1"
    radiobutton $i.useFF -text "Form Factor" -variable ::SQGUI::useNonFFSq  -value "0"
    label $i.temp1 -text "  "
    label $i.temp4 -text "  "
    button $i.computeSel -text {Compute Selections} -command [namespace code computeSelections]
    
    grid $i.al $i.at $i.bl $i.bt -row 0 -sticky snew
    grid $i.al1 $i.at1 $i.bl1 $i.bt1 $i.cl1 $i.ct1 $i.temp3 -row 1 -sticky snew
    grid $i.al2 $i.usenonFF $i.useFF $i.temp1 $i.temp4 $i.computeSel -row 2 -sticky snew
    grid columnconfigure $i 0 -weight 2
    grid columnconfigure $i 1 -weight 2
    grid columnconfigure $i 2 -weight 2
    grid columnconfigure $i 3 -weight 2
    grid columnconfigure $i 4 -weight 1
    grid columnconfigure $i 5 -weight 2
    # grid columnconfigure $i 6 -weight 2
    
    #################
    # subdivide and layout the q range of interest frame
    set i $w.in1
    label $i.al -text "Left q:" 
    # define a slider using scale
    scale $i.at -orient horizontal -length 100 -sliderlength 30 -variable ::SQGUI::leftBin 
    label $i.bl -text "Right q:"
    scale $i.bt -orient horizontal -length 100 -sliderlength 30 -variable ::SQGUI::rightBin
    label $i.tmp -text "     "
    button $i.computeRanks -text {Compute Rankings} -command [namespace code DisplayStatsForSelections]
    grid $i.al $i.at $i.bl $i.bt $i.tmp $i.computeRanks -row 0 -sticky snew
    grid columnconfigure $i 0 -weight 2
    grid columnconfigure $i 1 -weight 2
    grid columnconfigure $i 2 -weight 2
    grid columnconfigure $i 3 -weight 2    
    grid columnconfigure $i 4 -weight 1    
    grid columnconfigure $i 5 -weight 2

    #################
    # subdivide and layout the visualization settings frame
    #bins frame
    frame $w.in2.topNframe
    frame $w.in2.topNOptionframe
    grid $w.in2.topNframe -row 1 -column 0 -sticky snew
    grid $w.in2.topNOptionframe -row 0 -column 0 -sticky snew
    grid columnconfigure $w.in2 0 -minsize 500 -weight 1    
    grid rowconfigure    $w.in2 0 -weight 1 
    grid rowconfigure    $w.in2 0 -weight 1 
    #top N contributors frame
    set i $w.in2.topNframe
    label $i.al -text "Top N Atomic Contributors:" 
    scale $i.at -orient horizontal -length 120 -sliderlength 30  -resolution 1 -variable ::SQGUI::topN
    label $i.bl -text "Selected Atom (Serial):" 
    scale $i.bt -orient horizontal -length 120 -sliderlength 30  -resolution 1 -variable ::SQGUI::atomsAll
    label $i.temp2 -text "  "
    grid $i.al $i.at $i.bl $i.bt $i.temp2  -row 0 -sticky snew 
    
    grid columnconfigure $i 0 -weight 2
    grid columnconfigure $i 1 -weight 4
    grid columnconfigure $i 2 -weight 2
    grid columnconfigure $i 3 -weight 4
    grid columnconfigure $i 4 -weight 1

    #top N atoms or molecules frame
    set i $w.in2.topNOptionframe
    label $i.tmp -text "  "
    label $i.choosel -text "Visualization Option:"
    radiobutton $i.dispatoms    -text "Top N Atoms" -variable ::SQGUI::displayAtoms  -value "1"
    radiobutton $i.dispmolecules -text "Molecules Containing Top N Atoms" -variable ::SQGUI::displayAtoms  -value "0"

    label $i.betal -text "Beta Option:"
    radiobutton $i.betaRank    -text "Rank" -variable ::SQGUI::addBeta  -value "1"
    radiobutton $i.betaScore -text "Score" -variable ::SQGUI::addBeta  -value "0"
    label $i.tmp1 -text "  "

    label $i.al1 -text "Selection1:" 
    entry $i.at1 -width 20 -textvariable ::SQGUI::vis_selection1
    
    label $i.al2 -text "Coloring Method:" -width 20
    set color_methods {"Name" "Type" "Element" "ResName" "ResType" "ResID" "Chain" "SegName" "Conformation" "Molecule" 
                "Secondary Structure" "ColorID" "Beta" "Occupancy" "Mass" "Charge" "Fragment" "Index" "Backbone" "Throb"}    
    ttk::combobox $i.a_cb1 -textvariable ::SQGUI::selection1_color_method -values $color_methods -width 15 -justify left -state normal
    set selection1_color_method "ColorID"
    $i.a_cb1 set "ColorID"

    label $i.al3 -text "ColorID:"
    set colors {}
    for {set k 0} {$k < 16} {incr k} {
        lappend colors $k   
    }
    ttk::combobox $i.a_cb2 -textvariable ::SQGUI::selection1_colorId -values $colors -width 5 -justify left -state normal
    $i.a_cb2 set 0

    label $i.al4 -text "Material:"
    set materials {"Opaque" "Transparent" "BrushedMetal" "Diffuse" "Ghost" "Glass1" "Glass2" "Glass3" "Glossy" "HardPlastic" "MetallicPastel" 
                    "Steel" "Translucent" "Edgy" "EdgyShiny" "EdgyGlass" "Goodsell" "AOShiny" "AOChalky" "AOEdgy" "BlownGlass" "GlassBubble" "RTChrome"}
    ttk::combobox $i.a_cb3 -textvariable ::SQGUI::selection1_material -values $materials -width 15 -justify left -state normal
    $i.a_cb3 set "Transparent"

    label $i.al5 -text "Drawing Method:"
    set draw_methods {"Lines" "Bonds" "DynamicBonds" "Points" "VDW" "CPK" "Licorice" "Polyhedra" "Trace" "Tube" "Ribbons" "NewRibbons" "Cartoon" 
                        "NewCartoon" "QuickSurf" "Surf" "Beads" "Dotted" "Solvent"}
    ttk::combobox $i.a_cb4 -textvariable ::SQGUI::selection1_draw_method -values $draw_methods -width 15 -justify left -state normal
    $i.a_cb4 set "VDW"

    label $i.bl1 -text "Selection2:" 
    entry $i.bt1 -width 20 -textvariable ::SQGUI::vis_selection2
    
    label $i.bl2 -text "Coloring Method:" -width 20
    ttk::combobox $i.b_cb1 -textvariable ::SQGUI::selection2_color_method -values $color_methods -width 15 -justify left -state normal
    set selection2_color_method "ColorID"
    $i.b_cb1 set "ColorID"

    label $i.bl3 -text "ColorID:"
    ttk::combobox $i.b_cb2 -textvariable ::SQGUI::selection2_colorId -values $colors -width 5 -justify left -state disabled
    set selection2_colorId 0
    $i.b_cb2 set 0

    label $i.bl4 -text "Material:"
    ttk::combobox $i.b_cb3 -textvariable ::SQGUI::selection2_material -values $materials -width 15 -justify left -state normal
    set selection2_material "Transparent"
    $i.b_cb3 set "Transparent"

    label $i.bl5 -text "Drawing Method:"
    ttk::combobox $i.b_cb4 -textvariable ::SQGUI::selection2_draw_method -values $draw_methods -width 15 -justify left -state normal
    set selection2_draw_method "VDW"
    $i.b_cb4 set "VDW"

    label $i.cl1 -text "Selection3:" 
    entry $i.ct1 -width 20 -textvariable ::SQGUI::vis_selection3
    
    label $i.cl2 -text "Coloring Method:" -width 20
    ttk::combobox $i.c_cb1 -textvariable ::SQGUI::selection3_color_method -values $color_methods -width 15 -justify left -state normal
    set selection3_color_method "ColorID"
    $i.c_cb1 set "ColorID"

    label $i.cl3 -text "ColorID:"
    ttk::combobox $i.c_cb2 -textvariable ::SQGUI::selection3_colorId -values $colors -width 5 -justify left -state disabled
    set selection3_colorId 0
    $i.c_cb2 set 0
    label $i.cl4 -text "Material:"
    ttk::combobox $i.c_cb3 -textvariable ::SQGUI::selection3_material -values $materials -width 15 -justify left -state normal
    set selection3_material "Transparent"
    $i.c_cb3 set "Transparent"

    label $i.cl5 -text "Drawing Method:"
    ttk::combobox $i.c_cb4 -textvariable ::SQGUI::selection3_draw_method -values $draw_methods -width 15 -justify left -state normal
    set selection3_draw_method "VDW"
    $i.c_cb4 set "VDW"

    label $i.dl1 -text "Selection4:" 
    entry $i.dt1 -width 20 -textvariable ::SQGUI::vis_selection4
    
    label $i.dl2 -text "Coloring Method:" -width 20
    ttk::combobox $i.d_cb1 -textvariable ::SQGUI::selection4_color_method -values $color_methods -width 15 -justify left -state normal
    set selection4_color_method "ColorID"
    $i.d_cb1 set "ColorID"

    label $i.dl3 -text "ColorID:"
    ttk::combobox $i.d_cb2 -textvariable ::SQGUI::selection4_colorId -values $colors -width 5 -justify left -state disabled
    set selection4_colorId 0
    $i.d_cb2 set 0

    label $i.dl4 -text "Material:"
    ttk::combobox $i.d_cb3 -textvariable ::SQGUI::selection4_material -values $materials -width 15 -justify left -state normal
    set selection4_material "Transparent"
    $i.d_cb3 set "Transparent"

    label $i.dl5 -text "Drawing Method:"
    ttk::combobox $i.d_cb4 -textvariable ::SQGUI::selection4_draw_method -values $draw_methods -width 15 -justify left -state normal
    set selection4_draw_method "VDW"
    $i.d_cb4 set "VDW"

    label $i.el1 -text "Selection5:" 
    entry $i.et1 -width 20 -textvariable ::SQGUI::vis_selection5
    
    label $i.el2 -text "Coloring Method:" -width 20
    ttk::combobox $i.e_cb1 -textvariable ::SQGUI::selection5_color_method -values $color_methods -width 15 -justify left -state normal
    set selection5_color_method "ColorID"
    $i.e_cb1 set "ColorID"

    label $i.el3 -text "ColorID:"
    ttk::combobox $i.e_cb2 -textvariable ::SQGUI::selection5_colorId -values $colors -width 5 -justify left -state disabled
    set selection5_colorId 0
    $i.e_cb2 set 0

    label $i.el4 -text "Material:"
    ttk::combobox $i.e_cb3 -textvariable ::SQGUI::selection5_material -values $materials -width 15 -justify left -state normal
    set selection5_material "Transparent"
    $i.e_cb3 set "Transparent"

    label $i.el5 -text "Drawing Method:"
    ttk::combobox $i.e_cb4 -textvariable ::SQGUI::selection5_draw_method -values $draw_methods -width 15 -justify left -state normal
    set selection5_draw_method "VDW"
    $i.e_cb4 set "VDW"
        
    grid $i.al1 $i.at1  $i.al2 $i.a_cb1 $i.al3 $i.a_cb2 $i.al4 $i.a_cb3 $i.al5 $i.a_cb4 -row 0 -sticky snew
    grid $i.bl1 $i.bt1  $i.bl2 $i.b_cb1 $i.bl3 $i.b_cb2 $i.bl4 $i.b_cb3 $i.bl5 $i.b_cb4 -row 1 -sticky snew
    grid $i.cl1 $i.ct1  $i.cl2 $i.c_cb1 $i.cl3 $i.c_cb2 $i.cl4 $i.c_cb3 $i.cl5 $i.c_cb4 -row 2 -sticky snew
    grid $i.dl1 $i.dt1  $i.dl2 $i.d_cb1 $i.dl3 $i.d_cb2 $i.dl4 $i.d_cb3 $i.dl5 $i.d_cb4 -row 3 -sticky snew
    grid $i.el1 $i.et1  $i.el2 $i.e_cb1 $i.el3 $i.e_cb2 $i.el4 $i.e_cb3 $i.el5 $i.e_cb4 -row 4 -sticky snew
    grid $i.choosel $i.dispmolecules  $i.dispatoms $i.tmp $i.betal $i.betaRank  $i.betaScore $i.tmp1 -row 5 -sticky snew

    grid columnconfigure $i 0 -weight 2
    grid columnconfigure $i 1 -weight 2
    grid columnconfigure $i 2 -weight 2
    grid columnconfigure $i 3 -weight 2
    grid columnconfigure $i 4 -weight 2
    grid columnconfigure $i 5 -weight 2
    grid columnconfigure $i 6 -weight 2
    grid columnconfigure $i 7 -weight 2
    grid columnconfigure $i 8 -weight 2
    grid columnconfigure $i 9 -weight 2

    # call update molecule file list method
    UpdateMolfile
    # call enable or disable UI controls method
    EnDisable

    # Thought to be required by VMD based on other plug-in implementations.
    global vmd_molecule
    trace variable vmd_molecule w ::SQGUI::UpdateMolfile
    trace variable ::SQGUI::molid w ::SQGUI::EnDisable
}

# enable/disable buttons that depend on a proper molecule being selected
proc ::SQGUI::EnDisable {args} {
    variable molid
    variable w
    variable enableStatistics
    variable enableSelections
    variable enableRankings

    # If not valid mol file selected disable the calculate S(q) button.
    if {$molid < 0 } {
        $w.foot configure -state disabled
    } else {
        $w.foot configure -state normal
    }

    # If S(q) calculations are done, we enable the selections text boxes for further processing.
    if {$enableSelections==0} {
        $w.sel.computeSel configure -state disabled
        $w.sel.at configure -state disabled
        $w.sel.bt configure -state disabled
        $w.sel.at1 configure -state disabled
        $w.sel.bt1 configure -state disabled
        $w.sel.ct1 configure -state disabled
    } else {
        $w.sel.computeSel configure -state normal
        $w.sel.at configure -state normal
        $w.sel.bt configure -state normal
        $w.sel.at1 configure -state normal
        $w.sel.bt1 configure -state normal
        $w.sel.ct1 configure -state normal
    }

    # If compute selections is done, we enable the UI controls corresponding to q range sliders.
    if {$enableStatistics == 0} {
        $w.in1.computeRanks configure -state disabled
        $w.in1.at configure -state disabled
        $w.in1.bt configure -state disabled
        $w.in2.topNframe.at configure -state disabled
        $w.in2.topNframe.bt configure -state disabled
        $w.in2.topNOptionframe.dispatoms configure -state disabled
        $w.in2.topNOptionframe.dispmolecules configure -state disabled
        $w.in2.topNOptionframe.betaRank configure -state disabled
        $w.in2.topNOptionframe.betaScore configure -state disabled
        # $w.in2.topNframe.showVis configure -state disabled

    } else {
        $w.in1.computeRanks configure -state normal
        $w.in1.at configure -state normal
        $w.in1.bt configure -state normal       
    }

    # If compute ranking is done, we enable the UI controls corresponding to visualization settings.
    if {$enableRankings ==0} {
        $w.in2.topNframe.at configure -state disabled
        $w.in2.topNframe.bt configure -state disabled
        $w.in2.topNOptionframe.dispatoms configure -state disabled
        $w.in2.topNOptionframe.dispmolecules configure -state disabled
        $w.in2.topNOptionframe.betaRank configure -state disabled
        $w.in2.topNOptionframe.betaScore configure -state disabled
        # $w.in2.topNframe.showVis configure -state disabled

        $w.in2.topNOptionframe.at1 configure -state disabled
        $w.in2.topNOptionframe.a_cb1 configure -state disabled
        $w.in2.topNOptionframe.a_cb2 configure -state disabled
        $w.in2.topNOptionframe.a_cb3 configure -state disabled
        $w.in2.topNOptionframe.a_cb4 configure -state disabled

        $w.in2.topNOptionframe.bt1 configure -state disabled
        $w.in2.topNOptionframe.b_cb1 configure -state disabled
        $w.in2.topNOptionframe.b_cb2 configure -state disabled
        $w.in2.topNOptionframe.b_cb3 configure -state disabled
        $w.in2.topNOptionframe.b_cb4 configure -state disabled

        $w.in2.topNOptionframe.ct1 configure -state disabled
        $w.in2.topNOptionframe.c_cb1 configure -state disabled
        $w.in2.topNOptionframe.c_cb2 configure -state disabled
        $w.in2.topNOptionframe.c_cb3 configure -state disabled
        $w.in2.topNOptionframe.c_cb4 configure -state disabled

        $w.in2.topNOptionframe.dt1 configure -state disabled
        $w.in2.topNOptionframe.d_cb1 configure -state disabled
        $w.in2.topNOptionframe.d_cb2 configure -state disabled
        $w.in2.topNOptionframe.d_cb3 configure -state disabled
        $w.in2.topNOptionframe.d_cb4 configure -state disabled

        $w.in2.topNOptionframe.et1 configure -state disabled
        $w.in2.topNOptionframe.e_cb1 configure -state disabled
        $w.in2.topNOptionframe.e_cb2 configure -state disabled
        $w.in2.topNOptionframe.e_cb3 configure -state disabled
        $w.in2.topNOptionframe.e_cb4 configure -state disabled
    } else {
        $w.in2.topNframe.at configure -state normal
        $w.in2.topNframe.bt configure -state normal
        $w.in2.topNOptionframe.dispatoms configure -state normal
        $w.in2.topNOptionframe.dispmolecules configure -state normal
        $w.in2.topNOptionframe.betaRank configure -state normal
        $w.in2.topNOptionframe.betaScore configure -state normal
        # $w.in2.topNframe.showVis configure -state normal

        $w.in2.topNOptionframe.at1 configure -state normal
        $w.in2.topNOptionframe.a_cb1 configure -state normal
        $w.in2.topNOptionframe.a_cb2 configure -state normal
        $w.in2.topNOptionframe.a_cb3 configure -state normal
        $w.in2.topNOptionframe.a_cb4 configure -state normal

        $w.in2.topNOptionframe.bt1 configure -state normal
        $w.in2.topNOptionframe.b_cb1 configure -state normal
        $w.in2.topNOptionframe.b_cb2 configure -state normal
        $w.in2.topNOptionframe.b_cb3 configure -state normal
        $w.in2.topNOptionframe.b_cb4 configure -state normal

        $w.in2.topNOptionframe.ct1 configure -state normal
        $w.in2.topNOptionframe.c_cb1 configure -state normal
        $w.in2.topNOptionframe.c_cb2 configure -state normal
        $w.in2.topNOptionframe.c_cb3 configure -state normal
        $w.in2.topNOptionframe.c_cb4 configure -state normal

        $w.in2.topNOptionframe.dt1 configure -state normal
        $w.in2.topNOptionframe.d_cb1 configure -state normal
        $w.in2.topNOptionframe.d_cb2 configure -state normal
        $w.in2.topNOptionframe.d_cb3 configure -state normal
        $w.in2.topNOptionframe.d_cb4 configure -state normal

        $w.in2.topNOptionframe.et1 configure -state normal
        $w.in2.topNOptionframe.e_cb1 configure -state normal
        $w.in2.topNOptionframe.e_cb2 configure -state normal
        $w.in2.topNOptionframe.e_cb3 configure -state normal
        $w.in2.topNOptionframe.e_cb4 configure -state normal
    }
}

# update molecule list
proc ::SQGUI::UpdateMolfile {args} {
    variable w
    variable moltxt
    variable molid
    global vmd_molecule

    # Update the molecule browser
    set mollist [molinfo list]
    $w.in.molid.m configure -state disabled
    $w.in.molid.m.menu delete 0 end
    set moltxt "(none)"

    # loops through opened molecule files in VMD and add them to the menubutton created to show the list.
    if { [llength $mollist] > 0 } {
        $w.in.molid.m configure -state normal 
        foreach id $mollist {
            $w.in.molid.m.menu add radiobutton -value $id \
                -command {global vmd_molecule ; if {[info exists vmd_molecule($::SQGUI::molid)]} {set ::SQGUI::moltxt "$::SQGUI::molid:[molinfo $::SQGUI::molid get name]"} {set ::SQGUI::moltxt "(none)" ; set molid -1} } \
                -label "$id [molinfo $id get name]" \
                -variable ::SQGUI::molid
            if {$id == $molid} {
                if {[info exists vmd_molecule($molid)]} then {
                    set moltxt "$molid:[molinfo $molid get name]"  
                } else {
                    set moltxt "(none)"
                    set molid -1
                }
            }
        }
    } else {
        set moltxt "(none)"
        set molid -1
    }
}

# callback for VMD menu entry
proc viewsq_tk_cb {} {
  ::SQGUI::sqgui 
  return $::SQGUI::w
}