SELECT *
FROM Nashville_Housing

--Standardize SaleDate

SELECT SaleDate, CAST(Saledate as Date)   /*Funtion was not applied by system*/
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
	ADD NewDate date 

Update Nashville_Housing
SET NewDate = CAST(Saledate as Date)



--Elimated null Address
SELECT A.ParcelID, A.PropertyAddress,B.ParcelID, B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM Nashville_Housing A
JOIN Nashville_Housing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Nashville_Housing A
JOIN Nashville_Housing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL
/* All the Null PropertyAddress has been cleaned*/

--Breaking into PropertyAddress
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
FROM Nashville_Housing

SELECT SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD	PropertySplitAddress nvarchar(255)

UPDATE Nashville_Housing
SET		PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville_Housing
ADD	PropertySplitCity nvarchar(255)

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Nashville_Housing
/*PropertyAddress has been splited into PropertySplitAddress and PropertySplit*/

--Breaking into OwnerAddress
SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
   ,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
   ,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress Nvarchar (255)

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE Nashville_Housing
ADD OwnerSplitACity Nvarchar (255)

UPDATE Nashville_Housing
SET	OwnerSplitACity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE Nashville_Housing
ADD OwnerSplitState Nvarchar (255)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM Nashville_Housing
/*Owner Address has been splited into Address, City and State*/ 

-- SoldAsVacant

SELECT SoldAsVacant, COUNT(soldAsvacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT
	CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM Nashville_Housing

UPDATE Nashville_Housing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END
/* "SoldAsVacant" Column now is organzied as only "yes" or "no"*/ 

--Eliminate Duplicates
SELECT *
FROM Nashville_Housing

WITH RowNum_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference,TaxDistrict
	ORDER BY UniqueID) Row_num

FROM Nashville_Housing
)
SELECT *
FROM rownum_CTE
WHERE Row_num > 1

Delete
FROM rownum_CTE
WHERE Row_num > 1


--Eliminate unused column
SELECT *
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
DROP COLUMN SALEDATE, PropertyAddress, OwnerAddress,TaxDistrict

/*Unused Columns now are eliminated*/