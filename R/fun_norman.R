# function to add norman specific variables to a data.table
# for export of nor1 and nor2

norman = function(dt) {
  
  ## checks
  if (!is.data.table(dt)) {
    stop('Argument has to be a data.table')
  }
  ## copy
  nor = copy(dt)
  ## variables
  nor[ , biotest_id := paste0('EPA', result_id) ] # 1
  nor[ , data_source := 'EPA ECOTOX' ] # 2
  nor[ , data_protection := 'public available' ] # 5
  nor[ , data_source_link := 'https://cfpub.epa.gov/ecotox/' ] # 6
  nor[ , editor := 'Andreas Scharmüller' ] # 7
  nor[ , date := as.character(Sys.Date()) ] # 8
  # Reference
  nor[ , reference_type := 'n.a.' ] # 9
  nor[ , reference_id_norman := paste0('EPA', reference_number) ] # 10
  nor[ , testing_lab := 'n.a.' ]
  # Categorisatiion
  # Test substance
  # TODO NORMAN substance IDs
  nor[ , norman_substance_id := 'TODO' ] # 20
  nor[ , norman_cas := 'TODO' ] # 21
  nor[ , norman_ec := 'n.a.' ] # 22
  nor[ , test_item := 'n.a.' ] # 25
  nor[ , prep_stock := 'n.a.'] # 29
  # Biotest
  nor[ , standard_qualifier := 'n.a.' ] # 30
  nor[ , standard_deviation := 'n.a.' ] # 32
  nor[ , test_method_princip :=
          paste0(tes_additional_comments, ' ', res_additional_comments) ] # 33
  nor[ , glp_certificate := ifelse(test_method == 'GLP', 'yes', 'n.a.') ] #34
  nor[ ,  study_duration := 
          paste0(study_duration_mean, ' ', study_duration_unit) ] # 40
  nor[ , recovery := 'n.a.' ] # 41
  # Test organism
  nor[ , body_length_control := 'n.a.' ] # 45
  nor[ , body_length_unit := 'n.a.' ] # 46
  nor[ , cell_density_init := 'n.a.' ] # 49
  # Dosing system
  nor[ , culture_handling := 'n.a.' ] # 59
  nor[ , culture_acclimation := 'n.a.' ] # 60
  nor[ , conc_measured := 'n.a.' ] # 62
  nor[ , limit_test := 'n.a.' ] # 64
  nor[ , range_finding_study := 'n.a.' ] # 65
  nor[ , analytical_matrix := ifelse(chem_analysis_method %in%
                                        c('--', 'C', 'NC', 'NR', 'X', 'U'),
                                      'no',
                                      'yes') ] # 66
  nor[ , analytical_schedule := 'n.a.' ] # 67
  nor[ , analytical_method := 'n.a.' ] # 68
  nor[ , analytical_recovery := 'n.a.' ] # 69
  nor[ , loq := 'n.a.' ] # 70
  # Controls and study design
  nor[ , control_pos_substance := 'n.a.' ] # 78
  # TODO frome Edi
  # dd.vc AS "80", --Vehicle control",
  # vm.vehicle_mortality AS "81", --Effects in vehicle control",
  # TODO END
  nor[ , wat_quality_int := 'n.a.' ] # 82
  nor[ , wat_quality_int_unit := 'n.a.' ] # 83
  nor[ , media_ph_all := paste0(media_ph_mean, '(',
                                 media_ph_min, '-',
                                 media_ph_max, ')') ] # 84
  nor[ , media_ph_adjustment := 'n.a.' ] # 85
  nor[ , media_temperature_all := paste0(media_temperature_mean, '(',
                                          media_temperature_min, '-',
                                          media_temperature_max, ')') ] # 86
  nor[ , light_intensity := 'n.a.' ] # 90
  nor[ , light_intensity_unit := 'n.a.' ] # 91
  nor[ , light_quality := 'n.a.' ] # 92
  nor[ , light_period := 'n.a.' ] # 93
  nor[ , media_hardness_all := paste0(media_hardness_mean, '(',
                                       media_hardness_min, '-',
                                       media_hardness_max, ')') ] # 94
  nor[ , media_chlorine_all := paste0(media_chlorine_mean, '(',
                                       media_chlorine_min, '-',
                                       media_chlorine_max, ')') ] # 96
  nor[ , media_alkalinity_all := paste0(media_alkalinity_mean, '(',
                                         media_alkalinity_min, '-',
                                         media_alkalinity_max, ')') ] # 98
  nor[ , media_salinity_all := paste0(media_salinity_mean, '(',
                                       media_salinity_min, '-',
                                       media_salinity_max, ')') ] # 100
  nor[ , media_org_matter_all := paste0(media_org_matter_mean, '(',
                                         media_org_matter_min, '-',
                                         media_org_matter_max, ')') ] # 102
  nor[ , dissolved_oxygen_all := paste0(dissolved_oxygen_mean, '(',
                                         dissolved_oxygen_min, '-',
                                         dissolved_oxygen_max, ')') ] # 104
  nor[ , substrate := paste0(substrate, ';', substrate_description) ] # 106
  nor[ , vessel_material := 'n.a.' ] # 107
  nor[ , volume_container := 'n.a.' ] # 108
  nor[ , open_closed := 'n.a.' ] # 109
  nor[ , aeration := 'n.a.' ] # 110
  nor[ , test_medium := 'n.a.' ] # 111
  nor[ , culture_test_medium := 'n.a.' ] # 112
  nor[ , feeding_protocols := 'n.a.' ] # 113
  nor[ , food_type := 'n.a.' ] # 114
  # Biological effect
  nor[ , conc1_var := paste0(conc1_min, '-', conc1_max) ] # 124
  nor[ , result_comments := paste0(res_additional_comments, ';', test_characteristics) ] # 127
  nor[ , test_plausability := 'n.a.' ] # 128
  # TODO # 129
  nor[ , biological_response := ifelse(endpoint %like% '%*', 'no', 'yes') ] # 130
  nor[ , raw_data_availability := 'n.a.' ] # 131
  nor[ , comment_general := paste0(tes_additional_comments, ' ', res_additional_comments) ] # 133
  nor[ , rely_score := 5L ] # 134
  nor[ , rely_score_system := 'n.a.' ] # 135
  nor[ , rely_rational := 'n.a.' ] # 136
  nor[ , regulatory_purpose := 'n.a.' ] # 137
  nor[ , cell_density_fin := 'n.a.' ] # 138
  nor[ , purpose_flag := 'n.a.' ] # 139
  nor[ , rely_affiliation := 'n.a' ] # 140
  nor[ , cell_abnormal := 'n.a.' ] # 141
  nor[ , control_negative := 'n.a.' ] # 142
  nor[ , resp_description := tolower(resp_description) ] # 143
  nor[ , organism_lth_fin := 'n.a.' ] # 144
  nor[ , lipid_method := 'n.a.' ] # 145
  nor[ , ecotox_ds_id := 'n.a.' ] # 147
  nor[ , ctrl_description := tolower(ctrl_description) ] # 148
  
  return(nor)
  
}
