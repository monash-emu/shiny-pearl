library(data.table)


uppercase_col <- function(v) {
    if (is.character(v)) {
        return(toupper(v))
    } else {
        return(v)
    }
}

fix_hh_name <- function(col_name) {
    col_name <- gsub(pattern = "\\.", replacement = " ", x = col_name)
    col_name <- gsub(pattern = "  ", replacement = " ", x = col_name)
    col_name <- trimws(col_name, which = c("both"), whitespace = "[ \t\r\n]")
    return(col_name)
}

household_DT <- fread("data/HouseholdEnumeration_DATA_2023-05-31_1146_betio.csv")

screen_DT <- fread("data/PEARLScreeningBetio_DATA_LABELS_2023-05-31_1204.csv")

colnames(household_DT)
summary(household_DT)
str(household_DT)

names(screen_DT) <- readRDS("data/scn_column_names.rds")
colnames(screen_DT)
summary(screen_DT)
str(screen_DT)

hh_DT <- household_DT[, lapply(.SD, uppercase_col)]
hh_DT[, hh_name := fix_hh_name(hh_name)]

scn_DT <- screen_DT[, lapply(.SD, uppercase_col)]
fix_cols <- names(scn_DT)[grepl("dwelling", names(scn_DT))]

scn_DT[, (fix_cols) := lapply(.SD, fix_hh_name), .SDcols = fix_cols]

dwelling_col <- names(scn_DT)[grepl("dwelling", names(scn_DT), fixed = TRUE)]

scn_hh <- scn_DT[is.na(redcap_repeat_instrument), c("record_id", "ea_number", ..dwelling_col)]
screen_DT[, ea_number]



scn_hh[dwelling_name_71406110 != "HH NOT FOUND - NEW HH" & scn_hh$dwelling_name_71406110 != "", dwelling := dwelling_name_71406110]
scn_hh[dwelling_name_71406120 != "HH NOT FOUND - NEW HH" & scn_hh$dwelling_name_71406120 != "", dwelling := dwelling_name_71406120]
scn_hh[dwelling_name_71406210 != "HH NOT FOUND - NEW HH" & scn_hh$dwelling_name_71406210 != "", dwelling := dwelling_name_71406210]
scn_hh[dwelling_name_71406220 != "HH NOT FOUND - NEW HH" & scn_hh$dwelling_name_71406220 != "", dwelling := dwelling_name_71406220]
scn_hh[dwelling_new != "" & is.na(dwelling), dwelling := dwelling_new]

scn_hh <- scn_hh[, .(record_id, ea_number, dwelling)]
scn_DT <- scn_DT[scn_hh, on = .(record_id = record_id)]
scn_DT[, i.ea_number := NULL]


scn_DT <- scn_DT[hh_DT, on = .(dwelling = hh_name)]
fwrite(scn_DT, "output/scn_DT.csv")

# Errors that need to be reported
scn_DT[ea_number != hh_ea, .(record_id, ea_number, hh_ea)]
