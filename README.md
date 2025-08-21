# 🧹 Data Cleaning - Nashville Housing Dataset  

## 📌 Overview  
This project aims to demonstrate the importance of the **data cleaning** stage in any data analysis workflow.  
For this purpose, I used the **Nashville Housing dataset**, applying SQL techniques to fix inconsistencies, remove duplicates, and standardize information.  

With cleaner and more consistent data, future analysis and insights become **more accurate and reliable**.  

---

## 🎯 Project Goal  
- Correct and standardize inconsistent information in the dataset.  
- Handle null values and replace them logically.  
- Create new columns from existing data, making the dataset more structured.  
- Remove duplicates and unnecessary columns, leaving the dataset ready for analysis.  

---

## 🗂️ Data Cleaning Steps  

### 1️⃣ Standardizing Dates  
- The `SaleDate` column was in **datetime** format, containing both date and time.  
- Applied:  
  ```sql
  CONVERT(date, SaleDate)
to keep only the date, ensuring consistency.

### 2️⃣ Fixing Missing Property Addresses
Some rows were missing PropertyAddress.
Using ParcelID, I matched and filled in missing addresses from other records.

code used:
ISNULL(a.PropertyAddress, b.PropertyAddress)

### 3️⃣ Splitting Address Columns
Property addresses were stored in a single column.

Used functions like SUBSTRING, CHARINDEX, LTRIM, and RTRIM to split into:
AddressProperty → street
City → city

For OwnerAddress, I applied PARSENAME (after replacing commas with periods) to extract:
OwnerSplitAddress → street
OwnerCity → city
OwnerState → state

### 4️⃣ Standardizing Categorical Variables
The column SoldAsVacant contained numeric values (0 and 1).

Converted them into text values for better readability:
CASE 
    WHEN SoldAsVacant = 0 THEN 'No'
    WHEN SoldAsVacant = 1 THEN 'Yes'
END

### 5️⃣ Removing Duplicates
Duplicate records were detected in the dataset.

I used ROW_NUMBER() with PARTITION BY to identify duplicates and kept only the first valid record.

Example:
ROW_NUMBER() OVER (
  PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
  ORDER BY UniqueID
) row_num

Then, records with row_num > 1 were deleted.

### 6️⃣ Dropping Unused Columns
After cleaning and creating new structured columns, old redundant columns were removed:
OwnerAddress
PropertyAddress

### 🛠️ Key SQL Functions Used
UPDATE → to fix null values and standardize data.
PARSENAME → to split parts of strings (addresses).
ROW_NUMBER() → to detect duplicates.
LTRIM, RTRIM → to remove unnecessary spaces.
ISNULL → to fill missing values.

### 📊 Summary
The data cleaning process is a crucial step in any data project. In this case study, I:
✔️ Standardized date formats.
✔️ Fixed missing and unstructured addresses.
✔️ Created new columns from unorganized data.
✔️ Standardized categorical variables.
✔️ Removed duplicates and unused information.

As a result, the dataset is now much cleaner, standardized, and ready for accurate and reliable analysis.
