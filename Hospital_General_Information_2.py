import pandas as pd

df = pd.read_csv(r"C:\Users\srika\Downloads\Hospital_General_Information_2.csv")

print("Dataset shape:", df.shape)
print("\nColumn names:")
print(df.columns.tolist())

print("\nFirst 5 rows:")
print(df.head())

print("\nMissing values:")
print(df.isnull().sum())
print("Dataset shape:", df.shape)

print("Duplicate rows:", df.duplicated().sum())

print("Missing Facility IDs:", df["Facility ID"].isnull().sum())

print("Unique hospitals:", df["Facility ID"].nunique())
missing = df.isnull().sum()

print(missing[missing > 0].sort_values(ascending=False))
missing = df.isnull().sum()

print(missing[missing.index == "Meets criteria for birthing friendly designation"])
print(df["Meets criteria for birthing friendly designation"].value_counts(dropna=False))
print(df["Hospital overall rating"].value_counts(dropna=False))
print(df.dtypes)
df["Facility ID"] = df["Facility ID"].astype(str)
df["ZIP Code"] = df["ZIP Code"].astype(str)

print(df[["Facility ID", "ZIP Code"]].dtypes)
categorical_columns = [
    "Hospital Type",
    "Hospital Ownership",
    "Emergency Services",
    "Hospital overall rating"
]

for col in categorical_columns:
    print("\n", "=" * 40)
    print(col)
    print(df[col].value_counts(dropna=False))
print("Missing values in each column:")
print(df.isnull().sum().sort_values(ascending=False))
print("Total rows:", len(df))
print("Unique hospital IDs:", df["Facility ID"].nunique())
print("Duplicate hospital IDs:", df["Facility ID"].duplicated().sum())
important_columns = [
    "Hospital Type",
    "Hospital Ownership",
    "Emergency Services",
    "Hospital overall rating",
    "State",
    "City/Town"
]

print(df[important_columns].isnull().sum())
print(df["Hospital overall rating"].value_counts())
print("Number of states:", df["State"].nunique())
print(df["State"].value_counts().head(10))
print(df["Emergency Services"].value_counts(dropna=False))
print(pd.crosstab(
    df["Hospital Ownership"],
    df["Hospital overall rating"]
))
rating_table = pd.crosstab(
    df["Hospital Ownership"],
    df["Hospital overall rating"]
)

print(rating_table.to_string())
rating_percent = pd.crosstab(
    df["Hospital Ownership"],
    df["Hospital overall rating"],
    normalize="index"
) * 100

print(rating_percent.round(2).to_string())
rated_df = df[df["Hospital overall rating"] != "Not Available"]

rating_comparison = pd.crosstab(
    rated_df["Hospital Ownership"],
    rated_df["Hospital overall rating"],
    normalize="index"
) * 100

print(rating_comparison.round(2).to_string())
print("Duplicate IDs after removing spaces:",
      df["Facility ID"].astype(str).str.strip().duplicated().sum())

print("IDs with leading/trailing spaces:",
      (df["Facility ID"].astype(str) !=
       df["Facility ID"].astype(str).str.strip()).sum())

print("Missing hospital names:",
      df["Facility Name"].isnull().sum())

print("Duplicate hospital names:",
      df["Facility Name"].duplicated().sum())
duplicates = df[df["Facility Name"].duplicated(keep=False)]

print(duplicates[
    ["Facility ID", "Facility Name", "City/Town", "State"]
].sort_values("Facility Name").head(20))
df.to_csv(
    r"C:\Users\srika\Downloads\Hospital_General_Information_cleaned.csv",
    index=False
)

print("General Information exported successfully!")
print("Rows:", len(df))
print("Columns:", len(df.columns))