<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  version="1.0" exclude-result-prefixes="exist">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:param name="mode">browse</xsl:param>	 <!-- browse or search -->

  <!-- search terms -->
  <xsl:param name="field"/>
  <xsl:param name="value"/>
  <xsl:param name="letter"/>
  <xsl:param name="keyword"/>

  <!-- information about current set of results  -->
  <xsl:variable name="position"><xsl:value-of select="//@exist:start"/></xsl:variable>
  <xsl:param name="max"/>
  <xsl:variable name="total"><xsl:value-of select="//@exist:hits"/></xsl:variable>

  <!--  <xsl:include href="utils.xsl"/> -->
  <xsl:include href="common.xsl"/>

  <xsl:variable name="nl"><xsl:text> 
</xsl:text></xsl:variable>


  <xsl:template match="/">
    <xsl:apply-templates select="//profile"/>
    <xsl:apply-templates select="//alphalist"/>


    <xsl:choose>
      <xsl:when test="$field = 'bookshelf'">
        <div class="bookshelf">
          <p><xsl:value-of select="$total"/> books with spine images</p>
          <xsl:apply-templates select="//item" mode="bookshelf"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="itemlist"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="profile">
    <div class="browse">
      <h1>Select a browse category:</h1>
      <ul class="browse">
        <li><a href="browse.php?field=title">All Titles</a></li>
        <xsl:if test="./form = 'Edited'">
          <li><a href="browse.php?field=criticaledition">Critical Editions</a></li>
        </xsl:if>
        <li>Ethnicity: <xsl:apply-templates select="ethnicity"/></li>
        <li>Genre: <xsl:apply-templates select="genre"/></li>
        <li>Geography: <xsl:apply-templates select="geography"/></li>
        <li>Period: <xsl:apply-templates select="period"/></li>
        <li><a href="browse.php?field=publisher">Source Publisher List</a></li>
        <li><a href="browse.php?field=author">Author List</a></li>
        <li><a href="browse.php?field=subject">Subject List</a></li>
        <li><a href="browse.php?field=bookshelf">Bookshelf view</a></li>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="profile/ethnicity|profile/genre|profile/geography|profile/period">
    <a>
      <xsl:attribute name="href">browse.php?field=<xsl:value-of select="name()"/>&amp;value=<xsl:value-of select="."/></xsl:attribute>
      <xsl:value-of select="."/>
    </a>
    <xsl:if test="position() != last()">
      <xsl:text> | </xsl:text>
    </xsl:if>
  </xsl:template>



  <xsl:template name="itemlist">
    <xsl:if test="count(//item) > 0">

    <xsl:call-template name="total-jumplist"/>
    
    <xsl:if test="//item/hits">
      <p class="info">Click on the number of hits to see your search terms in context.</p>
    </xsl:if>

      <table class="browse">
        <thead style="font-size:small;">
        <tr>
          <xsl:if test="//item/hits"><th class="hits">hits</th></xsl:if>
          <th class="num">#</th>
          <xsl:if test="//item/title"><th>title</th></xsl:if>
          <xsl:if test="//item/author"><th>author</th></xsl:if>
          <xsl:if test="//item/date"><th>date</th></xsl:if>
          <xsl:if test="//item/ethnicity"><th>ethnicity</th></xsl:if>
          <xsl:if test="//item/genre"><th>genre</th></xsl:if>
          <xsl:if test="//item/geography"><th>geography</th></xsl:if>
          <xsl:if test="//item/period"><th>period</th></xsl:if>
          <xsl:if test="//item/publisher"><th>source publisher</th></xsl:if>
          <!--          <xsl:if test="//item/??"><th>collection</th></xsl:if> -->
	<xsl:if test="//item/subject"><th>subject</th></xsl:if>
        <xsl:if test="//item/editor"><th>editor</th></xsl:if>
        <xsl:if test="//item/collection"><th>collection</th></xsl:if>
      </tr>
    </thead>
    <tbody align="left" valign="top" style="font-size:small;">
      <xsl:apply-templates select="//item"/>
    </tbody>
  </table>
</xsl:if>
  
  </xsl:template>

  <xsl:template match="item">
    <tr>	<!-- calculate item's position in total result set -->
    <xsl:apply-templates select="hits" mode="table"/>
      <td class="num"><xsl:value-of select="position() + $position - 1"/>.</td>
      <xsl:value-of select="$nl"/>

      <!--      <xsl:apply-templates select="*[not(self::hits)]" mode="table"/> -->

      <!-- there should ALWAYS be a table cell for a field if any of
      the records include that field (e.g., some texts that have no date) -->

      <xsl:if test="//item/title">
        <td><xsl:apply-templates select="title" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/author">
        <td><xsl:apply-templates select="author" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/date">
        <td><xsl:apply-templates select="date" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/ethnicity">
        <td><xsl:apply-templates select="ethnicity" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/genre">
        <td><xsl:apply-templates select="genre" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/geography">
        <td><xsl:apply-templates select="geography" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/period">
        <td><xsl:apply-templates select="period" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/publisher">
        <td><xsl:apply-templates select="publisher" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/subject">
        <td><xsl:apply-templates select="subject" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/editor">
        <td><xsl:apply-templates select="editor" mode="table"/></td>
      </xsl:if>
      <xsl:if test="//item/collection">
        <td><xsl:apply-templates select="collection" mode="table"/></td>
      </xsl:if>

    </tr>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="item/*" mode="table">
    <xsl:if test="name() != 'id'">
      <xsl:apply-templates select="."/>
    </xsl:if>
  </xsl:template>

  <!-- don't display edited/unedited -->
  <xsl:template match="item/form" mode="table"/>

  <xsl:template match="item/hits" mode="table">
    <td class="hits">
      <a>
        <xsl:attribute name="href">kwic.php?id=<xsl:value-of select="../id"/>&amp;keyword=<xsl:value-of select="$keyword"/></xsl:attribute>
        <xsl:apply-templates select="."/>
      </a>
    </td>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <!-- display multiple authors for a single text in one table cell -->
  <xsl:template match="item/author" mode="table">
    <xsl:if test="count(preceding-sibling::author) > 0">
      <br/>
    </xsl:if>
    <xsl:apply-templates select="."/>
  </xsl:template>

  <!-- display multiple dates for a single text in one table cell -->
  <xsl:template match="item/date" mode="table">
    <xsl:if test="count(preceding-sibling::date) > 0">
      <br/>
    </xsl:if>
    <xsl:apply-templates select="."/>
  </xsl:template>




  <!-- display multiple collections for a single text in one table cell -->
  <xsl:template match="item/collection" mode="table">
    <xsl:if test="count(preceding-sibling::collection) > 0">
      <br/>
    </xsl:if>
        <span>
          <xsl:attribute name="class"><xsl:call-template name="collection-shorthand"/></xsl:attribute>
          <xsl:apply-templates select="."/>
        </span>
  </xsl:template>

  <!-- convert collection name into shorthand name (for css coloring, site urls) -->
  <xsl:template name="collection-shorthand">
    <!-- escape apostrophe by storing in a variable-->
    <xsl:variable name="advocacy">Women's Advocacy</xsl:variable>

    <xsl:choose>
      <xsl:when test=". = 'Genre Fiction'">
        genrefiction
      </xsl:when>
      <xsl:when test=". = 'Early Modern through the 18th Century'">
        earylmodern
      </xsl:when>
      <xsl:when test=". = 'Early 20th Century Literature'">
        twentieth
      </xsl:when>
      <xsl:when test=". = 'World War I'">
        worldwar1
      </xsl:when>
      <xsl:when test=". = 'Native American'">
        nativeamerican
      </xsl:when>
      <xsl:when test=". = 'Abolition, Freedom, and Rights'">
        abolition
      </xsl:when>
      <xsl:when test=". = $advocacy">
        advocacy
      </xsl:when>
    </xsl:choose>
  </xsl:template>


<!-- display multiple subjects for a single text in one table cell -->
<xsl:template match="item/subject" mode="table">
  <xsl:if test="count(preceding-sibling::subject) > 0">
    <br/>
  </xsl:if>
      <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="title">
  <a>
    <xsl:attribute name="href">toc.php?id=<xsl:value-of select="../id"/><xsl:if test="$keyword != ''">&amp;keyword=<xsl:value-of select="$keyword"/></xsl:if></xsl:attribute>
    <b><xsl:apply-templates/></b>
  </a>
</xsl:template>

<!-- browse list of unique authors: reg is attached to author, may include multiple names
  authoritative author name (title page name, other title page name(s)) --> 
<xsl:template match="author">
  <!-- canonical/regularized version of author name -->
  <xsl:variable name="reg">   	<!-- reg is in either one of these two places -->
    <xsl:value-of select="@reg"/>  
    <xsl:value-of select="name/@reg"/>
  </xsl:variable>
  <a>
    <xsl:attribute name="href">browse.php?field=author&amp;value=<xsl:value-of select="normalize-space($reg)"/></xsl:attribute>
    <xsl:value-of select="$reg"/>
  </a>
  <xsl:if test="$reg != name">	<!-- (only display if different) -->
    [<xsl:apply-templates select="name"/>] <!-- title page version(s) of author name -->
  </xsl:if>
</xsl:template>

<!-- possibly multiple names in authorlist mode -->
<xsl:template match="author/name">
  <a>
    <xsl:attribute name="href">browse.php?field=author&amp;value=<xsl:value-of select="normalize-space(.)"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>
  <xsl:if test="position() != last()">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>


<!-- do nothing with id itself --> <xsl:template match="id"/>

<xsl:template name="total-jumplist">


  <!-- only display total & jump list if there are actually results -->
  <xsl:if test="$total > 0">

    <xsl:variable name="url">
      <xsl:choose>
        <xsl:when test="$mode = 'browse'">browse.php?field=<xsl:value-of select="$field"/><xsl:if test="$value">&amp;value=<xsl:value-of select="$value"/></xsl:if><xsl:if test="$letter">&amp;letter=<xsl:value-of select="$letter"/></xsl:if>
      </xsl:when>
      <xsl:when test="$mode = 'search'">search.php?keyword=<xsl:value-of select="$keyword"/></xsl:when>
    </xsl:choose>
  </xsl:variable>

    <table class="searchnav">
      <!-- always build a table with four cells so spacing will be consistent -->
      <tr>
      <xsl:choose>
        <xsl:when test="$position != 1">

          <!-- start position for previous chunk -->
        <xsl:variable name="newpos">
          <!-- start position shouldn't go below 1 -->
          <xsl:call-template name="max">
            <xsl:with-param name="num1"><xsl:value-of select="($position - $max)"/></xsl:with-param>
            <xsl:with-param name="num2"><xsl:value-of select="1"/></xsl:with-param>
          </xsl:call-template>
        </xsl:variable>

          <td>
            <!-- don't display first if it is the same as previous -->
            <xsl:if test="$newpos != 1">
              <a>
                <xsl:attribute name="href"><xsl:value-of 
                select="concat($url, '&amp;position=1&amp;max=', $max)"/></xsl:attribute>
                &lt;&lt; First
              </a>
            </xsl:if>
        </td>          


        <td>
          <a>
            <xsl:attribute name="href"><xsl:value-of 
            select="concat($url, '&amp;position=', $newpos, '&amp;max=', $max)"/></xsl:attribute>
            &lt;Previous
          </a>          
        </td>
        </xsl:when>
        <xsl:otherwise>
          <td></td>	<!-- first -->
          <td></td>	<!-- prev  -->
        </xsl:otherwise>
      </xsl:choose>

      <!-- next -->

      <xsl:variable name="next-start">
        <xsl:value-of select="($position + $max)"/>
      </xsl:variable>

      <xsl:variable name="last-start">
        <xsl:value-of select="($total - $max + 1)"/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="($next-start - 1) &lt; $total">
          <td>
            <a>
            <xsl:attribute name="href"><xsl:value-of 
            select="concat($url, '&amp;position=', $next-start, '&amp;max=', $max)"/></xsl:attribute>
            Next&gt;
          </a>          
        </td>

        <td>
          <!-- don't display last if it is the same as next -->
          <xsl:if test="$next-start != $last-start">
            <a>
              <xsl:attribute name="href"><xsl:value-of 
              select="concat($url, '&amp;position=', $last-start, '&amp;max=', $max)"/></xsl:attribute>
              Last&gt;&gt;
            </a>          
          </xsl:if>
          
        </td>
        </xsl:when>
        <xsl:otherwise>
          <td></td>	<!-- next -->
          <td></td>	<!-- last -->
        </xsl:otherwise>
      </xsl:choose>
    </tr>
    </table>


  <xsl:variable name="chunksize"><xsl:value-of select="$max"/></xsl:variable>  
    <!-- only display jump list if there are more results than displayed here. -->
    <xsl:if test="$total > $chunksize">
      <form id="jumpnav">
        <xsl:attribute name="action"><xsl:value-of select="$mode"/>.php</xsl:attribute>
        <xsl:choose>
          <xsl:when test="$mode = 'browse'">
            <input name="field" type="hidden">
              <xsl:attribute name="value"><xsl:value-of select="$field"/></xsl:attribute>
            </input>
            <xsl:if test="$value">
              <input name="value" type="hidden">
                <xsl:attribute name="value"><xsl:value-of select="$value"/></xsl:attribute>
              </input>
            </xsl:if>
            <xsl:if test="$letter">
              <input name="letter" type="hidden">
                <xsl:attribute name="value"><xsl:value-of select="$letter"/></xsl:attribute>
              </input>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$mode = 'search'">
            <input name="keyword" type="hidden">
              <xsl:attribute name="value"><xsl:value-of select="$keyword"/></xsl:attribute>
            </input>
          </xsl:when>
        </xsl:choose>
        <input name="max" type="hidden">
          <xsl:attribute name="value"><xsl:value-of select="$max"/></xsl:attribute>
        </input>
        <select name="position" onchange="submit();">
          <xsl:call-template name="jumpnav-option"/>
        </select>
      </form>
    </xsl:if> 

    <xsl:element name="p">
      <xsl:value-of select="$total"/> match<xsl:if test="$total != 1">es</xsl:if> found
    </xsl:element>
  </xsl:if> 
</xsl:template>


<!-- recursive function to generates option values for jumpnav form 
     based on position, max, and total -->
<xsl:template name="jumpnav-option">
  <!-- position, max, and total are global -->
  <xsl:param name="curpos">1</xsl:param>	<!-- start at 1 -->
  
  <xsl:variable name="curmax">    
    <xsl:call-template name="min">
      <xsl:with-param name="num1">
        <xsl:value-of select="$curpos + $max - 1"/>
      </xsl:with-param>
      <xsl:with-param name="num2">
        <xsl:value-of select="$total"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <option> 
    <xsl:attribute name="value"><xsl:value-of select="$curpos"/></xsl:attribute>
    <!-- if this option is the content currently being displayed, mark as selected -->
    <xsl:if test="$curpos = $position">
      <xsl:attribute name="selected">selected</xsl:attribute>
    </xsl:if>
    <xsl:value-of select="$curpos"/> - <xsl:value-of select="$curmax"/>
  </option>

  <!-- if the end of this section is less than the total, recurse -->
  <xsl:if test="$total > $curmax">
    <xsl:call-template name="jumpnav-option">
      <xsl:with-param name="curpos">
        <xsl:value-of select="$curpos + $max"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template match="alphalist">
  <p class="alphalist">
    Browse by first letter:
    <a>
      <xsl:attribute name="href">browse.php?field=<xsl:value-of select="$field"/></xsl:attribute>
      ALL
    </a>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template match="alphalist/letter">
  <xsl:text> </xsl:text>
  <a>
    <xsl:attribute name="href">browse.php?field=<xsl:value-of select="$field"/>&amp;letter=<xsl:value-of select="."/></xsl:attribute>
    <xsl:value-of select="."/>
  </a>
  <xsl:text> </xsl:text>
</xsl:template>



<xsl:template match="item" mode="bookshelf">
<!-- paths for images : included from content (modified - all spines in genrefic) -->
<xsl:variable name="figure-prefix">http://bohr.library.emory.edu/ewwrp/image-content/tgfw/</xsl:variable>

<xsl:variable name="thumbs-prefix"><xsl:value-of select="$figure-prefix"/>thumbs/</xsl:variable>
<xsl:variable name="figure-suffix">.jpg</xsl:variable>
  

  <a>
  <xsl:attribute name="href">toc.php?id=<xsl:value-of select="id"/></xsl:attribute>
  <img>
    <xsl:attribute name="src"><xsl:value-of select="concat($thumbs-prefix, figure/@entity, $figure-suffix)"/></xsl:attribute>
    <xsl:attribute name="title"><xsl:value-of select="title"/></xsl:attribute>
    <xsl:attribute name="alt">book spine</xsl:attribute>
  </img>
</a>
</xsl:template>

</xsl:stylesheet>
