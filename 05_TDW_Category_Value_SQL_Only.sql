WITH Blocked_Disposal AS (SELECT DISTINCT 
      SUM(BLOCKED.[ValueBlock]) as 'Blocked Stock Value',
	  CAT.[Materials Team Categorie 1]

  FROM Reports.[CategoryReport_Blocked_without_Disposal_VT] as BLOCKED
JOIN TDW.MaterialCategories as CAT on BLOCKED.[Material] = CAT.[Material]
GROUP BY CAT.[Materials Team Categorie 1]
HAVING CAT.[Materials Team Categorie 1] NOT LIKE ''),

Missing_stock AS (SELECT DISTINCT 
	  SUM(MISSING.ValueUnrestricted) + SUM(MISSING.[ValueBlock]) as 'Missing Stock Value',
	  CAT.[Materials Team Categorie 1]

  FROM Reports.[CategoryReport_MissingStock] as MISSING
JOIN TDW.MaterialCategories as CAT on MISSING.[Material] = CAT.[Material]
GROUP BY CAT.[Materials Team Categorie 1]),

Vendor_Stock AS (SELECT DISTINCT 
	  SUM(VENDOR.[ValueUnrestricted]) as 'Vendor Stock Value',
	  CAT.[Materials Team Categorie 1] 

  FROM Reports.[CategoryReport_VendorStock] as VENDOR
JOIN TDW.MaterialCategories as CAT on VENDOR.[Material] = CAT.[Material]
GROUP BY CAT.[Materials Team Categorie 1]
HAVING CAT.[Materials Team Categorie 1] NOT LIKE '')

SELECT 
/*[ReportDate],*/
      [Category],
      [Exisiting Stock Value],
      [FF Value],
      [Disposal Stock Value],
      [Deffered Disposal Stock Value],
      [Reserved for Project],
      [Non-reserved for Project],
      [Reserved for Common (Network)],
      [Reserved for Common (Order)],
      [Covered by Replenishment Level],
      [Non-reserved for Common],
      [Handovered to Contractor],
      [PO Value],
      [PR Value],
	  COALESCE(Blocked_Disposal.[Blocked Stock Value],0) as 'Blocked Stock Value',
	  COALESCE(Missing_stock.[Missing Stock Value],0) as 'Missing Stock Value',
	  COALESCE(Vendor_Stock.[Vendor Stock Value],0) as 'Vendor Stock Value'

  FROM [MMDB].[TDW].[TDWC?tegoryReport] AS TDWCat
  /*WHERE [ReportDate] = '2020-11-06'*/
  
  LEFT JOIN Blocked_Disposal ON TDWCat.[Category] = Blocked_Disposal.[Materials Team Categorie 1]
  LEFT JOIN Missing_stock ON TDWCat.[Category] = Missing_stock.[Materials Team Categorie 1]
  LEFT JOIN Vendor_Stock ON TDWCat.[Category] = Vendor_Stock.[Materials Team Categorie 1]

  WHERE [ReportDate] = CAST( GETDATE() AS Date );