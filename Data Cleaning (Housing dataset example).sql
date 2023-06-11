-- Cleaning Data with SQL Queries

SELECT * 
FROM PortfolioProject..NashvilleHousing

-- Standardize/Change date (format)

SELECT	SaleDateConverted, CONVERT(Date,SaleDate) 
FROM PortfolioProject..NashvilleHousing

--This update didn't work when it should have
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Alter table to create sale date converted to remove the time from the date column
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate porperty address

SELECT	*
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
 JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) --You could populate the a.PropertyAddress with a string if their were no b.PropertAddress values like (a.PropertAddress,'No address')
FROM PortfolioProject.dbo.NashvilleHousing a
 JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Now when running the above SELECT statement nothing is return as the update statement would rectify the null Property Address rows with their corresponding data

--It is important to populate the data in the PropertyAddress values before the address is split up into separate columns to reduce workload to prevent having to correct the faulty address formating twice

--Separating the addres into individual columns (Address, City, State)

SELECT	PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--order by ParcelID

--the -1 and +1 are used to remove the ',' from the results for a neater final address form
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Now you should see two new columns at the end of the table 'PropertySplitAddress' and 'PropertySplitCity'



SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

--An example of using parsename instead of substring to separate the address into individual columns

--Parsename looks for periods(full stops) instead of commas
--The order is revresed to 3, 2, 1 as the parsename tends to reverse things in the sense that it would be in the state, city and address order so flip it preemptively for easier reading
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
-- Now you should see three new columns at the end of the table 'OwnerSplitAddress', 'OwnerSplitCity' and 'OwnerSplitState'

--Next task is to change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2
--The results show that Yes and No have more rows adhering to their categorisation

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--This above update statement has  turned the Y and N responses into their respective Yes and No responses
-- A standardised SoldAsVacant results (only 'Yes' and 'No')

--It is not standard practice to delete data within your database however...
--This task is to remove duplicates

WITH Row_NumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num 
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT * --Switched to DELETE statement from SELECT statement to remove duplicates and then back to SELECT statement to check the change (104 rows affected)
From Row_NumCTE 
WHERE row_num > 1
--order by PropertyAddress

--This above statement returns with no results proving that the duplicates are removed

-- This next task is to delete the unused columns

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

--PropertyAddress and OwnerAddress columns have been split up into more usable columns and SaleDate has been converted to a more relevant column displaying only the relevant data while TaxDistrict is not a necessary column

--The data is more usable now by cleaning the data

--Importing Data using OPENROWSET and BULK INSERT

sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'AD Hoc Distributed Queries' , 1;
RECONFIGURE;
GO

Use PortfolioProject

GO

Exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1

GO

Exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1

GO

-- Using BULK INSERT

USE PortfolioProject
Go

Select * 
From PortfolioProject.dbo.NashvilleHousing