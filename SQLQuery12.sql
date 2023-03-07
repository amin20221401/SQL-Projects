SELECT *
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

--Cleaning Date format

SELECT SaleDateConverted,CONVERT(Date, SaleDate)
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

---1)Sometimes you can do in this way

UPDATE NashvillHousing
SET SaleDate = CONVERT(Date, SaleDate)

---2)Prefer to do like this. ADD a column and update data.

ALTER TABLE NashvillHousing
ADD SaleDateConverted Date

UPDATE NashvillHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Cleaning Property Address Data. Looking for NULL and replace with correct data.

SELECT X.ParcelID, X.PropertyAddress, Y.ParcelID, Y.PropertyAddress , ISNULL(X.PropertyAddress , Y.PropertyAddress)
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing X
JOIN [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing Y
   ON X.ParcelID = Y.ParcelID
   AND X.UniqueID <> Y.UniqueID
WHERE X.PropertyAddress IS NULL

---Updating for replacing NULL with correct data

UPDATE X
SET PropertyAddress = ISNULL(X.PropertyAddress , Y.PropertyAddress)
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing X
JOIN [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing Y
   ON X.ParcelID = Y.ParcelID
   AND X.UniqueID <> Y.UniqueID
WHERE X.PropertyAddress IS NULL

--Breaking Addresse into individual columns (Address, City, State)
---1)Property Address

SELECT PropertyAddress
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

---With CHARINDEX function you can find the third position of SUBSRTING function.

SELECT
 SUBSTRING( PropertyAddress , 1 , CHARINDEX(',', PropertyAddress)-1) AS Address,
 SUBSTRING( PropertyAddress , CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS City
 FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

ALTER TABLE NashvillHousing
ADD PropertyAddress_Split NVARCHAR(255)

UPDATE NashvillHousing
SET PropertyAddress_Split = SUBSTRING( PropertyAddress , 1 , CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvillHousing
ADD PropertyCity_Splite NVARCHAR(255)

UPDATE NashvillHousing
SET PropertyCity_Splite = SUBSTRING( PropertyAddress , CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))

---For checking
SELECT PropertyAddress_Split , PropertyCity_Splite
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

---2)Owner Address (It's easier than previous method. Using PARSENAME function)

SELECT OwnerAddress
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

SELECT
PARSENAME(REPLACE(OwnerAddress , ',', '.') , 3) ,
PARSENAME(REPLACE(OwnerAddress , ',', '.') , 2) ,
PARSENAME(REPLACE(OwnerAddress , ',', '.') , 1) 
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

ALTER TABLE NashvillHousing
ADD OwnerAddress_Splite NVARCHAR(255)

UPDATE NashvillHousing
SET OwnerAddress_Splite = PARSENAME(REPLACE(OwnerAddress , ',', '.') , 3)

ALTER TABLE NashvillHousing
ADD OwnerCity_Splite NVARCHAR(255)

UPDATE NashvillHousing
SET OwnerCity_Splite = PARSENAME(REPLACE(OwnerAddress , ',', '.') , 2)

ALTER TABLE NashvillHousing
ADD OwnerState_Splite NVARCHAR(255)

UPDATE NashvillHousing
SET OwnerState_Splite = PARSENAME(REPLACE(OwnerAddress , ',', '.') , 1)

---For checking
SELECT OwnerAddress_Splite, OwnerCity_Splite, OwnerState_Splite
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing


-- Change Y to YES and N to NO in "Sold As Vacant field"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant ,
CASE WHEN SoldAsVacant = 'N' THEN 'NO'
	 WHEN SoldAsVacant = 'Y' THEN 'YES'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

UPDATE NashvillHousing
SET 
SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'NO'
	 WHEN SoldAsVacant = 'Y' THEN 'YES'
	 ELSE SoldAsVacant
	 END

--- For checking
SELECT SoldAsVacant
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing


--Remove Duplicates (CTE and WINDOWS function)
---ROW_NUMBER ()  Numbers the output of a result set. More specifically, returns the sequential number of a row within
---a partition of a result set, starting at 1 for the first row in each partition

WITH RowNumCTE AS (
SELECT * , 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS Row_Num
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing
)
--SELECT *
DELETE
FROM RowNumCTE
WHERE Row_Num >1
--ORDER BY PropertyAddress


--Delete Unused Columns

SELECT *
FROM [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing

ALTER TABLE [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing
DROP COLUMN SoldAsVacant_Changed , PropertyAddress , OwnerAddress, TaxDistrict

ALTER TABLE [Portfolio-Project-SQL02-Data Cleaning].dbo.NashvillHousing
DROP COLUMN SaleDate


	
	


