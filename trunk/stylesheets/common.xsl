<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  exclude-result-prefixes="exist" version="1.0">

  <xsl:include href="utils.xsl"/>

  <xsl:param name="url_suffix"/>
  <xsl:variable name="myurlsuffix"><xsl:if test="$url_suffix != ''">&amp;<xsl:value-of select="$url_suffix"/></xsl:if></xsl:variable>

  <xsl:template match="teiHeader">
    <h1><xsl:apply-templates select="//titleStmt/title"/></h1>
    <xsl:apply-templates select="//relative-toc"/>
    <p>by <xsl:apply-templates select="//titleStmt/author"/></p>
    <p>date: <xsl:apply-templates select="//sourceDesc/bibl/date"/><br/>
    source publisher: <xsl:apply-templates select="//sourceDesc/bibl/publisher"/>
    </p>
  </xsl:template>


  <!-- FIXME: should link to TOC when not at TOC view -->
  <xsl:template match="titleStmt/title">
  <xsl:choose>
    <xsl:when test="$mode = 'toc'">
      <b><xsl:apply-templates/></b>
    </xsl:when>
    <xsl:otherwise>
      <a>
        <xsl:attribute name="href">toc.php?id=<xsl:value-of select="//doc"/><xsl:value-of select="$myurlsuffix"/></xsl:attribute>
        <b><xsl:apply-templates/></b>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="author/name">
  <a>
    <xsl:attribute name="href">browse.php?field=author&amp;value=<xsl:value-of select="normalize-space(.)"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>

  <!-- if the regularized version of author name is different, display it -->
  <xsl:if test="@reg != .">
  [<a>
    <xsl:attribute name="href">browse.php?field=author&amp;value=<xsl:value-of select="normalize-space(@reg)"/></xsl:attribute>
    <xsl:value-of select="@reg"/>
  </a>]
  </xsl:if>
  
</xsl:template>


<xsl:template match="subject|publisher">
  <!-- convert special characters to url format -->
  <xsl:variable name="urlval">
    <xsl:call-template name="replace-string">
      <xsl:with-param name="string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
      <xsl:with-param name="from">&amp;</xsl:with-param>
      <xsl:with-param name="to">%26</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <a>
    <xsl:attribute name="href">browse.php?field=<xsl:value-of select="name()"/>&amp;value="<xsl:value-of select="$urlval"/>"</xsl:attribute>
    <xsl:apply-templates/>
  </a>
</xsl:template>

<!-- FIXME: add link to date search...  is this a search or a browse ? -->
<xsl:template match="date">
  <!--  <a>
    <xsl:attribute name="href">browse.php?field=date&amp;<xsl:value-of select="."/></xsl:attribute> -->
    <xsl:apply-templates/>
    <!--  </a> -->
</xsl:template>

<!-- table of contents, relative table of contents at item view level -->

<xsl:key name="item-by-parentid" match="item[parent/@id != '']" use="parent/@id"/>
<xsl:key name="item-by-parentid-and-parent" match="item[parent/@id != '']" 
  use="concat(parent/@id, ':', name(..))"/>

<xsl:template match="relative-toc/item|TEI.2/item|item[@name='text' and parent='group']|toc/item">
    <xsl:variable name="label">
      <xsl:call-template name="toc-label"/>
    </xsl:variable>

    <li>
      <xsl:choose>
        <!-- if this is the currently displayed node, don't make it a link -->
        <xsl:when test="@id = //content/*/@id">	<!-- could be div or titlePage -->
          <xsl:value-of select="$label"/>
        </xsl:when>
        <xsl:when test="@id = $id">
          <!-- this is the current node (may be displaying first content-level item under this node) -->
          <xsl:value-of select="$label"/>
        </xsl:when>
        <xsl:otherwise>
          <a>
            <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/><xsl:value-of select="$myurlsuffix"/></xsl:attribute>
            <xsl:value-of select="$label"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>

        <!-- in full TOC, only show one level in the back & front matter -->
        <xsl:if test="$mode != 'toc' or (parent != 'back' and parent != 'front')">
          <!-- if there are nodes under this one, display them now -->
          <xsl:if test="key('item-by-parentid-and-parent', concat(@id, ':', name(..)))">
            <ul>
              <xsl:apply-templates select="key('item-by-parentid-and-parent', 
                                           concat(@id, ':', name(..)))"/>
            </ul>
          </xsl:if>
        </xsl:if>

    </li>

  </xsl:template>


  <!-- generate nice display name for toc item -->
  <xsl:template name="toc-label">
      <xsl:choose>
        <xsl:when test="@name = 'front'">front matter</xsl:when>
        <xsl:when test="@name = 'back'">back matter</xsl:when>
        <xsl:when test="@name = 'titlePage'">
          title page
          <xsl:if test="@type">
            : <xsl:value-of select="@type"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="@name = 'text' and parent='group'">
        <!-- texts under group (composite text) : display title from titlepage -->
        <xsl:apply-templates select="titlePart"/>
      </xsl:when>
      <xsl:when test="@name = 'div'">
        <!-- only display type if it is not duplicated in the head (e.g., chapter) -->
        <xsl:if test="not(contains(
                      translate(head,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),
                      translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')))">
          <xsl:value-of select="@type"/>
          <xsl:if test="head"><xsl:text>: </xsl:text></xsl:if>
        </xsl:if>
        <xsl:if test="head != ''">	<!-- a couple of the outer, wrapping divs are blank -->
        <xsl:apply-templates select="head" mode="toc"/> 
      </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- nodes that don't display, and whose children shouldn't be indented -->
  <xsl:template match="item[@name='TEI.2'or @name='body' or @name='group']|item[@name='text' and parent!='group']">
    <xsl:apply-templates select="key('item-by-parentid', @id)"/>
  </xsl:template>


  <!-- convert line breaks into spaces when building TOC -->
  <xsl:template match="head/lb|head/milestone" mode="toc">
    <xsl:text> </xsl:text>
  </xsl:template>


  <xsl:template match="exist:match">
    <span class="match"><xsl:apply-templates/></span>
  </xsl:template>


</xsl:stylesheet>
