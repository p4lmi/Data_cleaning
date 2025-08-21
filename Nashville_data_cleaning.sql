select top 1000 * from NashvilleHousing


-- Standardizing Date Format
/* The column "sale date" is currently in datetime format. We need to remove the value "time" and keep only the sale date.*/
select SaleDate, convert(date, SaleDate) as SaleDate
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

-- Fixing property address
/* The Parcel ID corresponds to the Property Address. Several records were found with a null Property Address. In these cases, when the Parcel ID matches another record  
   that contains a populated Property Address, the null value will be replaced with the corresponding address to ensure data consistency.*/

select * from NashvilleHousing
--where PropertyAddress is null
order by ParcelID
-- Using ISNULL to replace null values in the "property address" column
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
order by a.ParcelID

-- Updating table to fix null values
UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Splitting address into individual columns (street, city, state)
select PropertyAddress from NashvilleHousing

select
    LTRIM(RTRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1))) AS Address,
    LTRIM(RTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)))) AS City
from NashvilleHousing
where CHARINDEX(',', PropertyAddress) > 0; -- filtering rows without a comma
/* CHARINDEX: finds "comma" position in the text	
SUBSTRING: extract part of the text
LTRIM, RTRIM: remove extra spaces from the text*/

-- Adding these separated table above to the database
alter table NashvilleHousing
add AddressProperty Nvarchar(150);
update NashvilleHousing
set AddressProperty = LTRIM(RTRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)))
where CHARINDEX(',', PropertyAddress) > 0


alter table NashvilleHousing
add City Nvarchar(150);
update NashvilleHousing
set City = LTRIM(RTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))))

select top 100 * from NashvilleHousing


select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), -- PARSENAME: extracts the last part of the address separated by a period (in this case, the street). It splits from right to left, so “3” represents the last portion on the right.
-- Since PARSENAME only separates by period, a REPLACE is needed to first switch commas to periods.
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(150);
update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerCity Nvarchar(150);
update NashvilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerState Nvarchar(150);
update NashvilleHousing
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Changing "Sold as Vacant" to "Yes or No". In our CSV file, No = 0 and Yes = 1, but using the words "Yes" and "No" is more intuitive and simplifies understanding.  

select distinct(SoldAsVacant), count(SoldAsVacant) from NashvilleHousing group by SoldAsVacant

select * from NashvilleHousing where SoldAsVacant is null

update NashvilleHousing
set SoldAsVacant = 0
where SoldAsVacant IS NULL;

alter table NashvilleHousing
alter column SoldAsVacant VARCHAR(3);

update NashvilleHousing
set SoldAsVacant = case 
    when SoldAsVacant = 0 THEN 'No'
    when SoldAsVacant = 1 THEN 'Yes'
end;

select SoldAsVacant from NashvilleHousing 


-- removing duplicates

select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by UniqueID) row_num
from NashvilleHousing

-- here we can a row with a UniqueID null. This is a miskate, lets check if there are more rows with null id and delete them
SELECT *
FROM NashvilleHousing
WHERE UniqueID IS NULL;
DELETE FROM NashvilleHousing
WHERE UniqueID IS NULL;
-- Found 3 rows with null UniqueID and incorrect information, now lets remove duplicates

-- removing duplicates

with RowNum as(
select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by UniqueID) row_num
from NashvilleHousing)
--order by ParcelID
DELETE from RowNum
where row_num > 1


-- deleting unused columns

select * from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, PropertyAddress

