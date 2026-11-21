import pandas as pd

file_path = r"C:\Users\srika\Downloads\HCAHPS_Hospital_cleaned.csv"

df = pd.read_csv(file_path, dtype=str)
numeric_columns = [
    "Patient Survey Star Rating",
    "HCAHPS Answer Percent",
    "HCAHPS Linear Mean Value",
    "Number of Completed Surveys",
    "Survey Response Rate Percent"
]

for col in numeric_columns:
    df[col] = pd.to_numeric(df[col], errors="coerce")

print(df[numeric_columns].dtypes)
print(df[numeric_columns].describe())
print(df[numeric_columns].isnull().sum())
print("Total rows and columns:", df.shape)
print("Duplicate rows:", df.duplicated().sum())
print("Unique hospitals:", df["Facility ID"].nunique())
print("Missing Facility IDs:", df["Facility ID"].isnull().sum())

print("Unique Facility IDs:", df["Facility ID"].nunique())

print(df["Facility ID"].head(10))
print(df["Facility ID"].value_counts().head(10))
hospital_counts = df["Facility ID"].value_counts()

print("Minimum rows per hospital:", hospital_counts.min())
print("Maximum rows per hospital:", hospital_counts.max())
print("Hospitals with 107 rows:", (hospital_counts == 107).sum())
print("Unique HCAHPS measures:",
      df["HCAHPS Measure ID"].nunique())

print("\nMost common measures:")
print(df["HCAHPS Measure ID"].value_counts().head(15))
print(df[[
    "HCAHPS Measure ID",
    "HCAHPS Question",
    "HCAHPS Answer Description"
]].head(20).to_string(index=False))
print(df["HCAHPS Answer Description"].value_counts().head(30))
print(
    df.groupby("HCAHPS Measure ID")[
        "HCAHPS Answer Description"
    ].nunique().sort_values().head(20)
)
print("Start dates:")
print(df["Start Date"].value_counts().head(10))

print("\nEnd dates:")
print(df["End Date"].value_counts().head(10))
# Check how many different answers each measure has
answer_check = df.groupby("HCAHPS Measure ID")[
    "HCAHPS Answer Description"
].nunique()

print(answer_check.head(20))
measure_dictionary = df[
    ["HCAHPS Measure ID", "HCAHPS Question", "HCAHPS Answer Description"]
].drop_duplicates()

print(measure_dictionary.to_string(index=False))
test = df[df["HCAHPS Measure ID"] == "H_RECMND_DY"]

print(test[[
    "Facility ID",
    "HCAHPS Measure ID",
    "HCAHPS Answer Description",
    "HCAHPS Answer Percent"
]].head(10))
test = df[df["HCAHPS Measure ID"] == "H_RECMND_DY"]

test = df[df["HCAHPS Measure ID"] == "H_RECMND_DY"]

print(
    test[[
        "Facility ID",
        "HCAHPS Measure ID",
        "HCAHPS Answer Description",
        "HCAHPS Answer Percent"
    ]].head(20).to_string(index=False)
)
print(
    test["HCAHPS Answer Description"]
    .value_counts()
)
print(
    test.groupby("HCAHPS Answer Description")[
        "HCAHPS Answer Percent"
    ].describe()
)
recommendation = df[
    df["HCAHPS Measure ID"].isin([
        "H_RECMND_DY",
        "H_RECMND_PY",
        "H_RECMND_DN"
    ])
]

print(
    recommendation[
        [
            "Facility ID",
            "HCAHPS Measure ID",
            "HCAHPS Answer Description",
            "HCAHPS Answer Percent"
        ]
    ].head(30).to_string(index=False)
)
df.to_csv(
    r"C:\Users\srika\Downloads\HCAHPS_Hospital_cleaned.csv",
    index=False
)

print("HCAHPS exported successfully!")
print("Rows:", len(df))
print("Columns:", len(df.columns))