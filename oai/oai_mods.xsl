<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.openarchives.org/OAI/2.0/"
  xmlns:oai_mods="http://www.loc.gov/mods/v3"
  xmlns:mods="http://www.loc.gov/standards/mods/v3/mods-3-0.xsd"
  version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:param name="prefix"/>

  <xsl:include href="xmldbOAI/xsl/response.xsl"/>
  <xsl:include href="sets.xsl"/>

  <!-- note: this variable MUST be set in order to use the setSpec template -->
  <xsl:variable name="config" select="document('./config.xml')" />	 

  <!-- list identifiers : header information only -->
  <xsl:template match="TEI.2" mode="ListIdentifiers">
    <xsl:call-template name="header"/>
  </xsl:template>

  <!-- get or list records : full information (header & metadata) -->
  <xsl:template match="TEI.2">
    <record>
    <xsl:call-template name="header"/>
    <metadata>
      <oai_mods:mods>
        <xsl:apply-templates select="teiHeader"/>
        <!-- FIXME: where should this go? -->
        <xsl:element name="mods:location">
          <xsl:element name="mods:url">PURL</xsl:element>
        </xsl:element> 

        <!-- FIXME: where should this go? -->
        <xsl:element name="mods:note">
          <xsl:text>Digital Edition Publication: </xsl:text>
          <xsl:value-of select="./teiHeader/fileDesc/publicationStmt/availability/p/address/addrLine[4]" />
          <xsl:text>, </xsl:text>
          <xsl:value-of select="./teiHeader/fileDesc/publicationStmt/availability/p/address/addrLine[1]" />
          <xsl:text>, </xsl:text>
          <xsl:value-of select="./teiHeader/revisionDesc/change[1]/date" />
        </xsl:element>

        <!--required by Aquifer-->
        <mods:typeOfResource>text</mods:typeOfResource>
        <mods:recordInfo>
          <mods:languageOfCataloging>
            <mods:languageTerm type="text" authority="iso639-2b">English</mods:languageTerm>
          </mods:languageOfCataloging>
          <mods:recordContentSource authority="marcorg">GEU</mods:recordContentSource>
          <mods:recordOrigin>reformatted from TEI</mods:recordOrigin>
        </mods:recordInfo>
      </oai_mods:mods>
    </metadata>
    </record>
  </xsl:template>

  <xsl:template name="header">
    <xsl:element name="header">            
      <xsl:element name="identifier">
        <!-- identifier prefix is passed in as a parameter; should be defined in config file -->
        <xsl:value-of select="concat($prefix, docname)" /> 
      </xsl:element>
      <xsl:element name="datestamp">
        <xsl:value-of select="LastModified" />
      </xsl:element>
      
      <!-- get set names from config.xml -->
      <xsl:apply-templates select=".//rs" mode="set"/>

    </xsl:element>
  </xsl:template>


  <xsl:template match="fileDesc/publicationStmt/availability">
    <xsl:element name="mods:accessCondition">
      <xsl:attribute name="type">useAndReproduction</xsl:attribute>
      <xsl:attribute name="displayLabel">Use and Reproduction</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="availability/p/text()">
    <xsl:choose>
      <xsl:when test="contains(., '&#xA9;')">
        <xsl:text>(c) </xsl:text>
        <xsl:value-of select="substring-after(., '&#xA9;')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>          
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- <xsl:template match="fileDesc/publicationStmt/availability/p/address">
    <xsl:element name="mods:accessCondition">
      <xsl:attribute name="type">rightsContact</xsl:attribute>
      <xsl:attribute name="label">Rights Contact</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>  -->

  <xsl:template match="addrLine">
    <xsl:if test="preceding-sibling::addrLine">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:value-of select="."/>
  </xsl:template> 

  <xsl:template match="profileDesc/creation/rs[@type='genre']">
    <xsl:element name="mods:genre">
      <xsl:attribute name="authority">local</xsl:attribute>

      <!-- map genre names to something more precise -->
      <xsl:choose>
        <xsl:when test=". = 'Novel'">Fiction</xsl:when>
        <xsl:when test=". = 'Prose'">Prose Literature</xsl:when>
        <xsl:otherwise>	<!-- Poetry, Drama, Short Stories, Periodical, etc. -->
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:element>    
  </xsl:template>

  <xsl:template match="profileDesc/creation/rs[@type='language']">
    <xsl:element name="mods:language">
      <xsl:element name="mods:languageTerm">
        <xsl:attribute name="type">text</xsl:attribute>
        <xsl:attribute name="authority">iso639-2b</xsl:attribute>
        <xsl:value-of select="."/>
      </xsl:element>		
      <xsl:element name="mods:languageTerm">
        <xsl:attribute name="type">code</xsl:attribute>
        <xsl:attribute name="authority">iso639-2b</xsl:attribute>
        
        <xsl:call-template name="language_lookup">
          <xsl:with-param name="lang"><xsl:value-of select="." /></xsl:with-param>
          <xsl:with-param name="authority">iso639-2b</xsl:with-param>
        </xsl:call-template> 
      </xsl:element>		
    </xsl:element> <!-- end mods:language -->

  </xsl:template>


  <xsl:template match="fileDesc/sourceDesc/bibl">
    <xsl:element name="mods:originInfo">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="fileDesc/sourceDesc/bibl/date">
      <xsl:element name="mods:dateCreated">
        <xsl:attribute name="keyDate">yes</xsl:attribute>
        <xsl:attribute name="encoding">w3cdtf</xsl:attribute>
      <xsl:value-of select="."/>
      </xsl:element>
  </xsl:template>

  <xsl:template match="fileDesc/sourceDesc/bibl/publisher">
      <xsl:element name="mods:publisher">
      <xsl:value-of select="."/>
      </xsl:element>
  </xsl:template>

  <xsl:template match="fileDesc/sourceDesc/bibl/pubPlace">
      <xsl:element name="mods:place">
        <xsl:element name="mods:placeTerm">
          <xsl:attribute name="type">text</xsl:attribute>
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:element>						
  </xsl:template>


  <xsl:template match="fileDesc/extent">
    <xsl:element name="mods:physicalDescription">
      <xsl:element name="mods:internetMediaType">text/xml</xsl:element>
      <xsl:element name="mods:extent"><xsl:value-of select="."/></xsl:element>
      <xsl:element name="mods:digitalOrigin">reformatted digital</xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="fileDesc/titleStmt/title">
    <xsl:element name="mods:titleInfo">

        <!-- parse out the title into non-sorting elements -->
        <xsl:call-template name="parse-title">
          <xsl:with-param name="title" select="."/>
        </xsl:call-template>

    </xsl:element>
  </xsl:template>


  <xsl:template match="profileDesc/textClass/keywords/list/item">
    <xsl:variable name="scheme"><xsl:value-of select="ancestor::keywords/@scheme"/></xsl:variable>

    <xsl:element name="mods:subject">
      <xsl:choose>
        <xsl:when test="$scheme != ''">
          <xsl:attribute name="authority"><xsl:value-of select="$scheme"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="authority">local</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <!-- FIXME: ideally, use more specific labels if possible: geographic, name, title, etc. -->
      <xsl:element name="mods:topic">
        <xsl:value-of select="."/>
      </xsl:element>

    </xsl:element>
  </xsl:template>

  <xsl:template match="fileDesc/titleStmt/author/name">
    <xsl:element name="mods:name">
      <xsl:attribute name="type">personal</xsl:attribute>
      <xsl:attribute name="authority">naf</xsl:attribute>
      <xsl:element name="mods:namePart"><xsl:value-of select="@reg" /></xsl:element>
      <xsl:element name="mods:role">
        <xsl:element name="mods:roleTerm">
          <xsl:attribute name="type">text</xsl:attribute>
          <xsl:attribute name="authority">marcrelator</xsl:attribute>Author</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
	

  <xsl:template match="node()">
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="text()"/>



  <!-- parse out the title into non-sorting characters, main title, and subtitle -->
  <xsl:template name="parse-title">
    <xsl:param name="title"/>    
    <!-- internal version of title with space normalized -->
    <xsl:variable name="_title" select="normalize-space($title)"/>    

    <xsl:variable name="squote"><xsl:text>'</xsl:text></xsl:variable>
    <xsl:variable name="quote"><xsl:text>"</xsl:text></xsl:variable>

    <xsl:choose>

      <!-- tag leading articles as nonsort; remove the space following -->
      <xsl:when test="starts-with($_title, 'The ')">
        <xsl:element name="mods:nonSort">The </xsl:element>
        <xsl:call-template name="parse-title">
          <xsl:with-param name="title" select="substring-after($_title, 'The ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($_title, 'THE ')">
        <xsl:element name="mods:nonSort">THE </xsl:element>
        <xsl:call-template name="parse-title">
          <xsl:with-param name="title" select="substring-after($_title, 'THE ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($_title, 'A ')">
        <xsl:element name="mods:nonSort">A </xsl:element>
        <xsl:call-template name="parse-title">
          <xsl:with-param name="title" select="substring-after($_title, 'A ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($_title, 'An ')">
        <xsl:element name="mods:nonSort">An </xsl:element>
        <xsl:call-template name="parse-title">
          <xsl:with-param name="title" select="substring-after($_title, 'An ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($_title, '$squote')">	<!-- single quote -->
        <xsl:element name="mods:nonSort">$squote</xsl:element>
        <xsl:call-template name="parse-title">
          <xsl:with-param name="title" select="substring-after($_title, $squote)"/>
        </xsl:call-template>
      </xsl:when>

      <!-- if the title is an electronic edition, remove the comma and mark as a subtitle -->
      <xsl:when test="contains($_title, ', an electronic edition')">
        <xsl:element name="mods:title">
          <xsl:value-of select="substring-before($_title, ', an electronic edition')"/>
        </xsl:element>
        <xsl:element name="mods:subTitle">an electronic edition</xsl:element>
      </xsl:when>

      <!-- nothing matches : all we have is the title -->
      <xsl:otherwise>
        <xsl:element name="mods:title">
          <xsl:value-of select="$_title"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
	

</xsl:stylesheet>
