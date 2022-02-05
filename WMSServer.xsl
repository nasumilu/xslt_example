<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:wms="http://www.opengis.net/wms"
  xmlns:esri_wms="http://www.esri.com/wms"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <xsl:output method="html" indent="yes"/>

<!-- Match the root of the xml document and begin transformation -->
<xsl:template match="/">
 <html>
   <head>
     <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
       rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3"
       crossorigin="anonymous"/>
     <link rel="stylesheet"
       href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css"/>

     <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/leaflet.min.css"
       integrity="sha512-1xoFisiGdy9nvho8EgXuXvnpR5GAMSjFwp40gSRE3NwdUdIMIKuPa7bqoUhLD0O/5tPNhteAsE5XyyMi5reQVA=="
       crossorigin="anonymous" referrerpolicy="no-referrer" />

     <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"
       integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p"
       crossorigin="anonymous"></script>

       <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/leaflet.min.js"
         integrity="sha512-SeiQaaDh73yrb56sTW/RgVdi/mMqNeM2oBwubFHagc5BkixSpP1fvqF47mKzPGWYSSy4RwbBunrJBQ4Co8fRWA=="
         crossorigin="anonymous" referrerpolicy="no-referrer"></script>

   </head>
   <body>
      <div class="container-fluid w-50 m-auto mt-5">
       <xsl:apply-templates/>
      </div>
   </body>
   <script>
     const mapDataset = document.getElementById('map').dataset;

     /* it is confusing to some but latitude is y-coorinate and
      * longitude is the x-coordinate. So when dealing with latlng the
      * ordered pair is (y,x)
      */
     const bounds = L.latLngBounds([
      L.latLng([mapDataset.miny, mapDataset.minx]),
      L.latLng([mapDataset.maxy, mapDataset.maxx])
     ]);

     const map = L.map('map', {
      zoomControl: false,
     }).setView(bounds.getCenter(), 3);

     L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&amp;copy; &lt;a href="https://www.openstreetmap.org/copyright"&gt;OpenStreetMap&lt;/a&gt; contributors'
     }).addTo(map);

     L.control.zoom({position: 'topright'}).addTo(map);

     // fix the incorrectly calcuated dimensions for the map when placed in a
     // display: none element.
     // @see https://stackoverflow.com/questions/35220431/how-to-render-leaflet-map-when-in-hidden-display-none-parent

     var tabEl = document.getElementById('map-tab');
     tabEl.addEventListener('shown.bs.tab', function (evt) {
        map.invalidateSize();
     });



     /* get the image format prefer image/png, image/jpeg | image/jpg, then image/tiff
      * if neither of the three are supported then the map will not load. It is
      * extremely unlikely that the service will not support these formats or at least
      * I'd consider using a service which is modern enough too. A case of my problem
      * or yours
      */
      const formats = mapDataset.formats.split(' ');
      let format;
      let transparent = false;
      if(formats.some(format => format === 'image/png')) {
        format = 'image/png';
        transparent = true;
      } else if(formats.some(format => format === 'image/jpeg' || format === 'image/jpg')) {
        format = formats.find(format => format === 'image/jpeg' || format === 'image/jpg');
      } else if(formats.some(format => format === 'image/tiff')) {
        format = 'image/tiff';
      }

     if(format) {
      let nexrad = L.tileLayer.wms(mapDataset.url, {
            layers: '1,2,3',
            format: format,
            transparent: transparent,
            version: mapDataset.wmsVersion,
            attribution: "National Weather Service"
            }).addTo(map);
    }


   </script>
 </html>
</xsl:template>

<!-- wms:WMS_Capabilities/wms:Service -->
<xsl:template match="wms:WMS_Capabilities/wms:Service">
  <h1><xsl:value-of select="wms:Title"/></h1>
  <xsl:apply-templates select="wms:ContactInformation"/>
</xsl:template>

<!-- wms:WMS_Capabilities/wms:Capability -->
<xsl:template match="wms:WMS_Capabilities/wms:Capability">
  <ul class="nav nav-tabs">
    <!-- Dropdown of supprted formats -->
    <li class="nav-item dropdown">
      <a class="nav-link dropdown-toggle"
         data-bs-toggle="dropdown"
         href="#"
         role="button"
         aria-expanded="false">
         Supported Formats
      </a>
      <ul class="dropdown-menu">
        <li>
          <a class="dropdown-item"
            id="image-formats-tab"
            data-bs-toggle="tab"
            data-bs-target="#image-formats"
            type="button"
            role="tab"
            href="#">
            Image Formats
          </a>
        </li>
        <li>
          <a class="dropdown-item"
            id="feature-formats-tab"
            data-bs-toggle="tab"
            data-bs-target="#feature-formats"
            type="button"
            role="tab"
            href="#">
            Feature Formats
          </a>
        </li>
        <li>
          <a class="dropdown-item"
            id="feature-formats-tab"
            data-bs-toggle="tab"
            data-bs-target="#exception-formats"
            type="button"
            role="tab"
            href="#">
            Exception Formats
          </a>
        </li>
      </ul>
    </li>
    <!-- End Dropdown of supprted formats -->
    <li class="nav-item dropdown">
      <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#" role="button" aria-expanded="false">Layers</a>
      <ul class="dropdown-menu">
        <xsl:for-each select="wms:Layer[wms:Layer]">
          <xsl:variable name="offset" select="position()"/>
          <li>
            <a class="dropdown-item"
              id="feature-formats-tab"
              data-bs-toggle="tab"
              data-bs-target="#layer-{$offset}"
              type="button"
              role="tab"
              href="#">
                <xsl:value-of select="wms:Title"/>&#160;&#160;
                <span class="badge bg-secondary"><xsl:value-of select="count(wms:Layer[wms:Layer])"/></span>
          </a>
        </li>
      </xsl:for-each>
      </ul>
    </li>
    <li class="nav-item">
      <a class="nav-link"
        id="map-tab"
        data-bs-toggle="tab"
        data-bs-target="#map-content"
        type="button"
        role="tab"
        aria-current="map-content" href="#">Map</a>
    </li>
  </ul>

  <xsl:variable name="bbox" select="/wms:WMS_Capabilities/wms:Capability/wms:Layer/wms:BoundingBox[@CRS='CRS:84']" />
  <xsl:variable name="url" select="/wms:WMS_Capabilities/wms:Service/wms:OnlineResource/@xlink:href" />
  <xsl:variable name="version" select="/wms:WMS_Capabilities/@version" />
  <xsl:variable name="formats" select="normalize-space(/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap[wms:Format])" />

  <div class="tab-content" id="feature-ontent">
    <xsl:apply-templates select="wms:Request" />
    <xsl:apply-templates select="wms:Exception" />
    <xsl:apply-templates select="wms:Layer" />
    <div class="tab-pane fade" id="map-content" role="tabpanel" aria-labelledby="map-content">
      <div id="map"
        style="height:550px"
        data-wms-version="{$version}"
        data-formats="{$formats}"
        data-url="{$url}"
        data-minx="{$bbox/@minx}"
        data-miny="{$bbox/@miny}"
        data-maxx="{$bbox/@maxx}"
        data-maxy="{$bbox/@maxy}">
      </div>
    </div>
  </div>
</xsl:template>

<!-- /wms:WMS_Capabilities/wms:Capability/wms:Request -->
<xsl:template match="wms:Request">
  <xsl:apply-templates select="wms:GetMap"/>
  <xsl:apply-templates select="wms:GetFeatureInfo"/>
</xsl:template>

<!-- /wms:WMS_Capabilities/wms:Service/wms:ContactInformation -->
<xsl:template match="wms:ContactInformation">

  <!-- Start ContactPerson -->
  <p>Contact Person:
  <xsl:choose>
    <xsl:when test="wms:ContactPersonPrimary/wms:ContactPerson != ''">
       <xsl:value-of select="wms:ContactPersonPrimary/wms:ContactPerson" />
    </xsl:when>
    <xsl:when test="wms:ContactPersonPrimary/wms:ContactPerson = ''">
      None
    </xsl:when>
  </xsl:choose>
</p>
<!-- End ContactPerson -->

<!-- Start ContactOrganization -->
  <p>Contact Organization:
  <xsl:choose>
    <xsl:when test="wms:ContactPersonPrimary/wms:ContactOrganization != ''">
       <xsl:value-of select="wms:ContactPersonPrimary/wms:ContactOrganization" />
    </xsl:when>
    <xsl:when test="wms:ContactPersonPrimary/wms:ContactOrganization = ''">
      None
    </xsl:when>
  </xsl:choose>
</p>
<!-- End ContactOrganization -->

<!-- Start ContactPosition -->
 <xsl:if test="wms:ContactPosition != ''">
   <p>Contact Position: <xsl:value-of select="wms:ContactPosition"/></p>
 </xsl:if>
 <!-- End ContactPosition -->
 <xsl:apply-templates select="wms:ContactAddress"/>
</xsl:template>

<xsl:template match="wms:ContactAddress">
</xsl:template>


<!--
  Template for wms:WMS_Capabilities/wms:Capability/wms:Exception
  This transforms the node into a boostrap tab-pane
-->

<xsl:template match="wms:Exception">
  <div class="tab-pane fade" id="exception-formats" role="tabpanel" aria-labelledby="exception-formats">
    <div class="card">
      <div class="card-body">
        <h2 class="card-title">Supported Exception Formats</h2>
        <ul class="list-unstyled">
          <xsl:for-each select="wms:Format">
            <li><i class="bi bi-exclamation-diamond"></i> &#160;&#160;<xsl:value-of select="."/></li>
          </xsl:for-each>
        </ul>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template match="wms:Layer">
  <xsl:variable name="offset" select="position()"/>
  <div class="tab-pane fade show active" id="layer-{$offset}" role="tabpanel" aria-labelledby="exception-formats">
    <div class="card">
      <div class="card-body">
        <h2 class="card-title"><xsl:value-of select="wms:Title"/></h2>
          <xsl:if test="wms:Abstract != ''">
            <blockquote class="blockquote">
              <p><xsl:value-of select="wms:Abstract"/></p>
            </blockquote>
          </xsl:if>
          <p>Supported Coordinate Reference Systems</p>
          <ul>
            <xsl:for-each select="wms:CRS">
              <li><xsl:value-of select="."/></li>
            </xsl:for-each>
          </ul>
          <xsl:apply-templates select="wms:EX_GeographicBoundingBox" />
          <xsl:if test="count(wms:Layer/wms:Layer) &gt; 0">
          <p>No. Sub-Layers: <xsl:value-of select="count(wms:Layer/wms:Layer)" /></p>
          </xsl:if>

      </div>
    </div>
  </div>


</xsl:template>

<!--
  Template for wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap
  This transforms the node into a boostrap tab-pane
-->
<xsl:template match="wms:GetMap">
  <div class="tab-pane fade" id="image-formats" role="tabpanel" aria-labelledby="image-formats">
    <div class="card">
      <div class="card-body">
        <h2 class="card-title">Supported Images Formats</h2>
        <ul class="list-unstyled">
          <xsl:for-each select="wms:Format">
            <li class=""><i class="bi bi-images"></i> &#160;&#160;<xsl:value-of select="."/></li>
          </xsl:for-each>
        </ul>
      </div>
    </div>
  </div>
</xsl:template>

<!--
  Template for wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetFeatureInfo
  This transforms the node into a boostrap tab-pane
-->

<xsl:template match="wms:GetFeatureInfo">
  <div class="tab-pane fade" id="feature-formats" role="tabpanel" aria-labelledby="image-formats">
    <div class="card">
      <div class="card-body">
        <h2 class="card-title">Supported Feature Formats</h2>
        <ul class="list-unstyled">
          <xsl:for-each select="wms:Format">
            <li class=""><i class="bi bi-geo-alt"></i> &#160;&#160;<xsl:value-of select="."/></li>
          </xsl:for-each>
        </ul>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template match="wms:EX_GeographicBoundingBox">
  <p>
    Boundary Box: (minx: <xsl:value-of select="wms:westBoundLongitude"/>,
    miny: <xsl:value-of select="wms:southBoundLatitude"/>,
    maxx: <xsl:value-of select="wms:eastBoundLongitude"/>,
    maxy: <xsl:value-of select="wms:northBoundLatitude"/>)
  </p>
</xsl:template>


</xsl:stylesheet>
