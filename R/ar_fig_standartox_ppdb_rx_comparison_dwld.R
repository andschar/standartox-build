# script to compare STANDARTOX estimates with toxicity data from other sources
# PPDB
# Chempropo
# GLP OECD studies only

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
# Standartox
q_stan = "SELECT
            cas,
            cname,
            tax_taxon AS taxon,
            concentration AS conc_stan,
            concentration_unit AS conc_unit_stan,
            duration AS dur,
            duration_unit AS dur_unit,
            endpoint,
            effect,
            exposure
          FROM standartox.tests_fin
          LEFT JOIN standartox.phch USING (casnr)
          LEFT JOIN standartox.taxa USING (species_number)
          WHERE endpoint ILIKE '%50%'"
stan = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q_stan)
# PPDB
q_ppdb = "SELECT
            cas,
            taxon,
            value * 1000 AS conc_ppdb,
            'ppb'::text AS conc_unit_ppdb,
            duration AS dur,
            duration_unit AS dur_unit,
            endpoint
          FROM ppdb.ppdb_data"
ppdb = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q_ppdb)
# Read across
q_rx = "SELECT cas, lc50_dm_rx
        FROM phch.phch_variables
        LEFT join phch.phch_variables_prop using (variable_id)"
rx = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = 'bfg_monitoring',
                query = q_rx)

# save --------------------------------------------------------------------
saveRDS(stan, file.path(cachedir, 'ar_standartox_comparison_stan.rds'))
saveRDS(ppdb, file.path(cachedir, 'ar_standartox_comparison_ppdb.rds'))
saveRDS(rx, file.path(cachedir, 'ar_standartox_comparison_rx.rds'))

# log ---------------------------------------------------------------------
log_msg('ARTICLE: PLOTS: STANDARTOX PPDB comparison download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()






