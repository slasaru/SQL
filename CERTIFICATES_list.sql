WITH CTE1 AS (
SELECT DISTINCT
	[Material Document Year] as 'Year',
	[Posting Date] as 'Date',
	[Movement Type] as 'Mvt Tupe',
	[Material Number] as 'MM',
	CRI.Description as 'Description',
	MB51.[Plant] as 'Plant',
	[Quantity] as 'Q-ty',
	MB51.[UOM] as 'UoM',
	[PO Number] as 'PO',
	[Item of PO] as 'PO Item',
	CAST(CONCAT([PO Number],'/',[Item of PO]) AS VARCHAR) as 'PO/LI',
	POs.Vendor as 'Vendor #',
	POs.[Vendor Name] as 'Vendor Name',
	POs.[WBS Element] as 'WBS',
	POs.Requisitioner as 'PR creator',
	POs.[Released By] as 'PO Releaser'
FROM [MMDB].[Inventory].[MB51] as MB51
LEFT JOIN General.V_CRIandRMMDMDMA as CRI
ON MB51.[Material Number] = CRI.Material
LEFT JOIN [Inventory].[ME80FN] as POs
ON [PO Number] = POs.[Purchasing Doc]
WHERE ([Material Document Year] = 2020 OR [Material Document Year] = 2021)
AND [Movement Type] IN (101, 107) 
AND [PO Number] LIKE '45%'
AND CRI.Loadinggroup = '0001'
AND POs.[Vendor Name] NOT IN 
	('BAKER HUGHES BV',
	'BAKER HUGHES OILFIELD OPERATION LLC',
	'CAMERON',
	'CAMERON (SINGAPORE) PTE LTD',
	'CAMERON FRANCE SAS',
	'CAMERON ROMANIA SRL',
	'CAMERON SERVICES RUSSIA LTD',
	'CHAMPION TECHNOLOGIES RUSSIA AND',
	'DRILLING SYSTEMS CAMERON MANIFOLD P',
	'FMC TECHNOLOGIES LTD',
	'INTERWELL NORWAY AS',
	'SCHLUMBERGER RESERVOIR PRODUCTS FZE',
	'SCHLUMBERGER VOSTOK LLC',
	'SUMITOMO CORPORATION EUROPE LTD',
	'WWT RUSSIA LTD')
),

CTE2 as(
SELECT DISTINCT MAIN.Material,
STUFF((SELECT ', ' + INTERIOR.VendorDocument 
FROM Cataloguing.MaterialVendorDocument INTERIOR WHERE INTERIOR.Material = MAIN.Material
for xml path('')), 1,1,'') as 'Required'
FROM Cataloguing.MaterialVendorDocument as MAIN
WHERE Material IN (SELECT DISTINCT MM FROM CTE1)
GROUP BY Material),

CTE3 AS (
SELECT DISTINCT
CAST(CONCAT([Purchase Document],'/',[Purchase Document Item]) AS varchar) as 'PoLi',
VRD.[Document Name] as 'DocName'
FROM RushReport.[Track.VendorDocumentLinks] as Links
LEFT JOIN RushReport.[Track.VendorDocuments] as VRD on Links.GUID = VRD.GUID
WHERE [Type] = 'VRD' and [Material Master] <> 0),

CTE4 AS(
SELECT DISTINCT MAIN.PoLi,
STUFF((SELECT ', ' + INTERIOR.DocName 
FROM CTE3 INTERIOR WHERE INTERIOR.PoLi = MAIN.PoLi
for xml path('')), 1,1,'') as 'Provided'
FROM CTE3 as MAIN
WHERE CAST(PoLi AS varchar) IN (SELECT DISTINCT [PO/LI] FROM CTE1)
GROUP BY PoLi)

SELECT 
	CTE1.Year,
	CTE1.Date,
	CTE1.[Mvt Tupe],
	CTE1.MM,
	CTE1.Description,
	CTE1.Plant,
	CTE1.[Q-ty],
	CTE1.UoM,
	CTE1.PO,
	CTE1.[PO Item],
	CTE1.[PO/LI],
	-- CAST(CTE4.PoLi as varchar) as 'Other PoLi',
	CTE1.[Vendor #],
	CTE1.[Vendor Name],
	CTE1.WBS,
	CTE1.[PR creator],
	CTE1.[PO Releaser],
	CTE2.Required,
	CTE4.Provided
FROM CTE1
LEFT JOIN CTE2 on CTE1.MM = CTE2.Material
LEFT JOIN CTE4 on CTE1.[PO/LI]  = CTE4.PoLi


