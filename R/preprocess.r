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

# The naming convention of the REDCap data downloads is ambiguous.
# Save the Betio HouseholdEnumeration data to the following filenames.

household_DT <- fread("data/HouseholdEnumeration_DATA_BETIO_RAW.csv")
col_names <- names(household_DT)
household_DT <- fread("data/HouseholdEnumeration_DATA_BETIO_LABELS.csv")

if (length(names(household_DT)) == length(col_names)) {
    names(household_DT) <- col_names
}


screen_DT <- fread("data/PEARLScreeningBetio_DATA_RAW.csv")
col_names <- names(screen_DT)
screen_DT <- fread("data/PEARLScreeningBetio_DATA_LABELS.csv")

if (length(names(screen_DT)) == length(col_names)) {
    names(screen_DT) <- col_names
}

colnames(household_DT)
summary(household_DT)
str(household_DT)

colnames(screen_DT)
summary(screen_DT)
str(screen_DT)

hh_DT <- household_DT[, lapply(.SD, uppercase_col)]
hh_DT[, hh_name := fix_hh_name(hh_name)]



scn_DT <- screen_DT[, lapply(.SD, uppercase_col)]
fix_cols <- names(scn_DT)[grepl("dwelling", names(scn_DT))]
# Remove "dwelling_id" as it is not a text column
fix_cols <- fix_cols[fix_cols != "dwelling_id"]


scn_DT[, (fix_cols) := lapply(.SD, fix_hh_name), .SDcols = fix_cols]

# Merge on the dwelling_id (screen) and record_id (Household Enumeration)
final_DT <- scn_DT[hh_DT, on = .(dwelling_id = record_id)]
fwrite(final_DT, "output/final_DT.csv")
