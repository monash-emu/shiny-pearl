import pandas as pd
from pathlib import Path
import os
from pandas.api.types import is_object_dtype


os.getcwd()
# Filesystem paths
BASE_PATH = Path(os.getcwd())

DATA_PATH = BASE_PATH / "data"

HH_EUM_NANIKAI = DATA_PATH / "HouseholdEnumeration_DATA_NANIKAI_LABELS.csv"
HH_EUM_BETIO = DATA_PATH / "HouseholdEnumeration_DATA_BETIO_LABELS.csv"

SCN_PEARL_REBUILD = DATA_PATH / "PEARLLaunchRebuild_DATA_LABELS.csv"
SCN_BETIO = DATA_PATH / "PEARLScreeningBetio_DATA_LABELS.csv"


def uppercase_df(df: pd.DataFrame) -> pd.DataFrame:
    return df.apply(lambda x: x.str.upper().str.strip() if is_object_dtype(x) else x)


def fix_dwelling_names(df: pd.DataFrame, col_list: list[str]) -> pd.DataFrame:
    for col in col_list:
        df[col] = df[col].str.replace(".", " ")

        while df[col].str.contains("  ", na=False, regex=False).any():
            df[col] = df[col].str.replace("  ", " ")
        df[col] = df[col].str.strip()

    return df


# Nanikai Household
hh_nanikai = pd.read_csv(HH_EUM_NANIKAI)
hh_nanikai_colnames = pd.read_csv(
    DATA_PATH / "HouseholdEnumeration_DATA_NANIKAI_RAW.csv"
)

# Same columns renamed acroos Nanikai & Betio
fix_columns = {
    "hh_census_id": "hh_census_intkey",
    "hh_name_2020census": "hh_census_dwname",
    "hh_size_2020census": "hh_census_hsize",
    "hh_censusnew": "hh_census_new",
    "hh_villiage": "hh_village",
    "hh_pc": "hh_sc_pc",
}

hh_nanikai_colnames.rename(columns=fix_columns, inplace=True)

nanikai_col_mapping = dict(zip(hh_nanikai_colnames.columns, hh_nanikai.columns))

hh_nanikai.columns = hh_nanikai_colnames.columns
# Drop unmatched columns
hh_nanikai.drop(columns=["hh_fu_status", "hh_otherstaff", "hh_photo"], inplace=True)

# Betio Household
hh_betio = pd.read_csv(HH_EUM_BETIO)
hh_betio_colnames = pd.read_csv(DATA_PATH / "HouseholdEnumeration_DATA_BETIO_RAW.csv")
hh_betio_col_mapping = dict(zip(hh_betio_colnames, hh_betio.columns))

hh_betio.columns = hh_betio_colnames.columns


# Combined household information
hh_enum = pd.concat([hh_betio, hh_nanikai])
hh_enum = hh_enum.reset_index(drop=True)
hh_enum = uppercase_df(hh_enum)
hh_enum.to_csv("hh.csv", index=False)


# Screening data for 'Rebuild'
scn_rebuild = pd.read_csv(SCN_PEARL_REBUILD)
scn_pearl_rebuild_colnames = pd.read_csv(DATA_PATH / "PEARLLaunchRebuild_DATA_RAW.csv")

scn_rebuild_mapping = dict(zip(scn_pearl_rebuild_colnames.columns, scn_rebuild.columns))

scn_rebuild.columns = scn_pearl_rebuild_colnames.columns


# Screening data for Betio
scn_betio = pd.read_csv(SCN_BETIO)
scn_betio_colnames = pd.read_csv(DATA_PATH / "PEARLScreeningBetio_DATA_RAW.csv")

scn_betio_mapping = dict(zip(scn_betio_colnames.columns, scn_betio.columns))

scn_betio.columns = scn_betio_colnames.columns

# The difference between these two dataset columns is too great
scn_rebuild.columns.difference(scn_betio.columns)
scn_betio.columns.difference(scn_rebuild.columns)

# Work with Betio data for now.
hh_betio = uppercase_df(hh_betio)
scn_betio = uppercase_df(scn_betio)

# get rid of the dots and remove the double spacing
hh_betio = fix_dwelling_names(hh_betio, ["hh_census_dwname", "hh_name", "hh_name_new"])
scn_betio = fix_dwelling_names(scn_betio, ["dwelling_name", "dwelling_new"])

# Remove duplicated records hh_name ignoring other columns
# The problem is more complicated e.g.hh_name TETOA IEBARE, TEMAROIETA TOOMA have two different
# hh_census_hsize, hh_census_intkey?
hh_betio = hh_betio.drop_duplicates("hh_name")

# Missing dwelling_name but has a new name
new_dwelling = scn_betio["dwelling_name"].isna() & (~scn_betio["dwelling_new"].isna())


scn_betio["dwelling_fixed"] = scn_betio["dwelling_name"]
scn_betio.loc[new_dwelling, "dwelling_fixed"] = scn_betio["dwelling_new"]

scn_betio = scn_betio[~scn_betio["dwelling_fixed"].isna()]
scn_betio = scn_betio.merge(
    hh_betio, "left", left_on="dwelling_fixed", right_on="hh_name"
)

scn_betio = scn_betio.rename(
    columns={"record_id_x": "record_id_scn", "record_id_y": "record_id_hh"}
)

scn_betio.to_csv(BASE_PATH / "output" / "scn_betio.csv", index=False)
