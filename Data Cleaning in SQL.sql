

/* DATA CLEANING IN SQL 


*/

SELECT * FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------
--Standardize Date format

SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateUpdated DATE;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateUpdated = CONVERT(DATE, SaleDate);

SELECT SaleDateUpdated FROM
PortfolioProject.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------
----Populate Property Address Data

SELECT PropertyAddress FROM
PortfolioProject.dbo.NashvilleHousing

SELECT * FROM
PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

/*Where Property Address is null, populate it with values from property Address that has the same ParcelID with it */

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-----------------------------------------------

-----Breaking down address into individual fields (Street, City, State)

-------Breaking Down Property Address

SELECT PropertyAddress FROM
PortfolioProject.dbo.NashvilleHousing

/*Char Index specifies the position of a value */
/* -1 is to remove the comma after the street address */
SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Street,
SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing

/* Create and update Property Street field */
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitStreet Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitStreet = SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1);

/* Create and update Property City field */
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(50);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) 

-----Breaking Down Owner Address

SELECT OwnerAddress FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM PortfolioProject.dbo.NashvilleHousing

/* Create and Update Owner Street Field */
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerStreet Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

/** Create and Update Owner City field **/
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerCity Nvarchar(50);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

/** Create and Update Owner State field */
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerState Nvarchar(50);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-----------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

/*Count Distinct fields in SoldAsVacant */
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing

/* Update Records*/
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
----Remove Duplicates
WITH BaseTable AS (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			  UniqueID
			  )row_num
FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
) SELECT * 
FROM BaseTable
WHERE row_num >1
Order By PropertyAddress
------------------------------------------------------------------------
----Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate

