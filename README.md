# XSLT Example

This is an example I used in class to show my fellow students how 
xsl can transform xml into other formats. 

The long and short of it is the `WMSServer.xml` is a copy of National Weather
Service (NWS) Base Reflectivity Radar Web Map Server (WMS) [GetCapabilities
response][1].

The `WMSServer.xsl` file transform the xml into hmtl and javascript to show
services capabilites and produces a webmap with the Leaflet.js package. 


[1]:https://idpgis.ncep.noaa.gov/arcgis/services/NWS_Observations/radar_base_reflectivity/MapServer/WMSServer?request=GetCapabilities&service=WMS
