import pandas as pd

df = pd.read_csv(
    r"C:\Users\srika\Downloads\hrrp.csv",
    dtype=str
)

print("Dataset shape:", df.shape)

print("\nColumn names:")
print(df.columns.tolist())

print("\nFirst 5 rows:")
print(df.head())
print("Missing values:")
print(df.isnull().sum())

print("\nData types:")
print(df.dtypes)

print("\nUnique hospitals:")
print(df["Facility ID"].nunique())

print("\nUnique measures:")
print(df["Measure Name"].nunique())
print("\nFootnote values:")
print(df["Footnote"].value_counts(dropna=False))
print("\nMeasure distribution:")
print(df["Measure Name"].value_counts())
print("Duplicate rows:", df.duplicated().sum())

print("Duplicate hospital-measure pairs:",
      df.duplicated(subset=["Facility ID", "Measure Name"]).sum())
print("\nMissing values by measure:")

print(
    df.groupby("Measure Name")[
        ["Number of Discharges",
         "Excess Readmission Ratio",
         "Predicted Readmission Rate",
         "Expected Readmission Rate",
         "Number of Readmissions"]
    ].apply(lambda x: x.isnull().sum())
)
columns_to_check = [
    "Number of Discharges",
    "Excess Readmission Ratio",
    "Predicted Readmission Rate",
    "Expected Readmission Rate",
    "Number of Readmissions"
]

missing_percentage = (
    df.groupby("Measure Name")[columns_to_check]
    .apply(lambda x: x.isnull().mean() * 100)
)

print("\nMissing value percentages by measure:")
print(missing_percentage.round(2))
print("\nFootnote distribution:")
print(df["Footnote"].value_counts(dropna=False))
print("\nFootnote vs missing readmission ratio:")

print(
    df.groupby("Footnote", dropna=False)
    ["Excess Readmission Ratio"]
    .apply(lambda x: x.isnull().sum())
)
print("\nFootnote vs missing readmission ratio:")

print(
    df.groupby("Footnote")["Excess Readmission Ratio"]
    .apply(lambda x: x.isnull().mean() * 100)
    .round(2)
)
print(
    df.groupby("Measure Name")["Footnote"]
    .value_counts(dropna=False)
)
footnote_percentage = (
    df.groupby("Measure Name")["Footnote"]
    .value_counts(normalize=True, dropna=False)
    .mul(100)
    .round(2)
)
hrrp_clean = df.copy()

numeric_cols = [
    "Number of Discharges",
    "Excess Readmission Ratio",
    "Predicted Readmission Rate",
    "Expected Readmission Rate",
    "Number of Readmissions"
]


print(footnote_percentage)
print("HRRP Start Dates:")
print(df["Start Date"].value_counts(dropna=False))

print("\nHRRP End Dates:")
print(df["End Date"].value_counts(dropna=False))
for col in numeric_cols:
    invalid = hrrp_clean[
        pd.to_numeric(hrrp_clean[col], errors="coerce").isna()
        & hrrp_clean[col].notna()
    ][col].value_counts()

    print(f"\n{col}")
    print(invalid)
for col in numeric_cols:
    hrrp_clean[col] = pd.to_numeric(
        hrrp_clean[col],
        errors="coerce"
    )

print(hrrp_clean[numeric_cols].dtypes)

print("\nMissing values after conversion:")
print(hrrp_clean[numeric_cols].isnull().sum())    
hrrp_clean.to_csv(
    r"C:\Users\srika\Downloads\hrrp_cleaned.csv",
    index=False
)

print("HRRP cleaned dataset saved successfully!")
print("Rows:", len(hrrp_clean))
print("Columns:", len(hrrp_clean.columns))
check = pd.read_csv(
    r"C:\Users\srika\Downloads\hrrp_cleaned.csv"
)

print("Shape:", check.shape)
print("Duplicate rows:", check.duplicated().sum())
print("Missing Facility IDs:", check["Facility ID"].isna().sum())
print("Numeric data types:")
print(check[numeric_cols].dtypes)