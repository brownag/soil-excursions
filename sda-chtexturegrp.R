# get horizon by index, depth/depth range, filtered by criteria of interest
get_SDA_texture("texture", "DOMINANT CONDITION", areasymbol = "CA630")

# surface horizon
SDA_query("SELECT legend.lkey, mapunit.mukey, component.cokey, chorizon.chkey, 
                  FIRST_VALUE(hzname) OVER (ORDER BY chorizon.chkey) AS hzname,
                  STRING_AGG(CONCAT(texture, CASE WHEN rvindicator = 'Yes' THEN '*' ELSE '' END), ' ') AS texture
           FROM chorizon
           INNER JOIN chtexturegrp ON chorizon.chkey = chtexturegrp.chkey
           INNER JOIN component ON chorizon.cokey = component.cokey
           INNER JOIN mapunit ON component.mukey = mapunit.mukey
           INNER JOIN legend ON mapunit.lkey = legend.lkey
           WHERE hzdept_r >= 10 AND hzdepb_r <= 50
           AND areasymbol IN ('CA630')
           GROUP BY legend.lkey, mapunit.mukey, component.cokey, chorizon.chkey, chorizon.hzname")
