SELECT	T.Segment,
    T.Material, 
    md.Description, 
    md.UOM, 
    SUM(T.[Stock Quantity]) AS [Stock Quantity], 
    SUM(T.[Stock Value]) AS [Stock Value($)],
    CAT.[Materials Team Categorie 1],
	CASE WHEN CAT.ReviewYear LIKE '%deff%' THEN 'Deferred'
		WHEN CAT.[Materials Team Categorie 1] LIKE '%OCTG%' THEN 'OCTG'
		WHEN CAT.[Materials Team Categorie 1] LIKE '%hemicals%' THEN 'Chemical'
		WHEN CAST(T.Material AS nvarchar) IN (SELECT DISTINCT [Material] FROM [MMDB].[TDW].[TMLContent]
		WHERE [TMLID] IN (SELECT [ID] FROM [MMDB].[TDW].[TMLS] WHERE [InSequence] = 'X' and [Deleted] != 'X') AND [History] != 'X') THEN 'TML' 
		WHEN T.Segment LIKE 'Excessive' THEN 'Excessive'
	ELSE 'Not Assigned' END AS [Final]

FROM  (SELECT 'Capex' AS Segment, 
    CRC.Material, 
    CRC.[Stock Quantity],
	CRC.[Stock Value], 
    CRC.MRPArea, 
    CRC.Directorate
    FROM Reports.CategoryReport_capex AS CRC
UNION ALL

SELECT 'Opex', 
    CRO.Material,
	CRO.[Stock Quantity], 
    CRO.[Stock Value], 
    CRO.MRPArea, 
    CRO.Directorate 
    FROM Reports.CategoryReport_opex AS CRO 
UNION ALL 

SELECT 'MinMax', 
    CRMMC.Material,
	CRMMC.[Stock Qty Covered by MinMax], 
    CRMMC.[Stock value Covered by MinMax], 
    CRMMC.MRPArea, 
    CRMMC.Directorate 
    FROM Reports.CategoryReport_MinMax_Common AS CRMMC 
UNION ALL 

SELECT 'Excessive', 
    CREC.Material,
	CREC.[Excessive Qty],
    CREC.[Excessive Value], 
    CREC.MRPArea, 
    CREC.Directorate 
    FROM Reports.CategoryReport_Excessive_Common AS CREC
UNION ALL 

SELECT 'Emergency', 
    CRES.Material,
	CRES.Unrestricted, 
    CRES.ValueUnrestricted, 
    CRES.MRPArea, 
    CRES.Directorate 
    FROM Reports.CategoryReport_Emergency_Stock AS CRES 
UNION ALL 

SELECT 'FF', 
    CRFS.Material, 
	CRFS.Qty, 
    CRFS.Value, 
    CRFS.MRPArea, 
    CRFS.Directorate 
    FROM Reports.CategoryReport_FF_Stock AS CRFS 
UNION ALL 

SELECT 'Disposal', 
    CRD.Material,
    CRD.Unrestricted+CRD.TransitTransf+CRD.Blocked AS Qty,  
    CRD.ValinTransTfr+CRD.ValueUnrestricted+CRD.ValueBlock AS Disposal, 
    CRD.MRPArea, 
    CRD.Directorate 
    FROM Reports.CategoryReport_Disposal AS CRD 
UNION ALL 

SELECT 'Discrep', 
    CRMS.Material,
	CRMS.Unrestricted+CRMS.Blocked, 
    CRMS.ValueUnrestricted+CRMS.ValueBlock AS Value, 
    CRMS.MRPArea, 
    CRMS.Directorate 
    FROM Reports.CategoryReport_MissingStock AS CRMS 
UNION ALL 

SELECT 'Vendor(repairing)', 
    CRVS.Material,
	CRVS.Unrestricted,  
    CRVS.ValueUnrestricted, 
    CRVS.MRPArea, 
    CRVS.Directorate 
    FROM Reports.CategoryReport_VendorStock AS CRVS 
UNION ALL 

SELECT 'Blocked Stock (e.g. prepared for repairing, or will be transferred to Disposal)', 
    CRBWDV.Material,
	CRBWDV.Blocked, 
    CRBWDV.ValueBlock, 
    CRBWDV.MRPArea, 
    CRBWDV.Directorate 
    FROM Reports.CategoryReport_Blocked_without_Disposal_VT AS CRBWDV 
UNION ALL 

SELECT 'Handed over to contractor for usage', 
    CRHTC.Material,
    CRHTC.Unrestricted,  
    CRHTC.ValueUnrestricted, 
    CRHTC.MRPArea, 
    CRHTC.Directorate 
    FROM Reports.CategoryReport_Handovered_to_Contractor AS CRHTC) AS T 

JOIN General.MaterialDescription AS md 
ON md.Material = T.Material 
LEFT JOIN [TDW].[MaterialCategories] as CAT on T.Material = CAT.Material

GROUP BY T.Segment,
	T.Directorate,
	T.Material, 
	md.Description, 
	md.[Manufacturer Name], 
	md.UOM, 
	T.MRPArea, 
	CAT.[Materials Team Categorie 1],
	CAT.ReviewYear
HAVING SUM(T.[Stock Quantity]) > 0 AND T.Material != 1000317946 AND T.Directorate = 'TD|Technical Directorate';