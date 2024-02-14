<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:ns2="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns="http://pkp.sfu.ca" version="1.0">
  <xsl:output method="xml" encoding="utf-8" indent="yes"/>
  <xsl:param name="section_ref" />
  <xsl:param name="seq" />
  <xsl:param name="access_status" />
  <xsl:param name="volume" />
  <xsl:param name="number" />
  <xsl:param name="year" />
  
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="issue">
    <issue>
      <xsl:attribute name="published">
        <xsl:choose>
          <xsl:when test="@published = 'true'">
            <xsl:value-of select="1" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="0" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="current">
        <xsl:choose>
          <xsl:when test="@current = 'true'">
            <xsl:value-of select="1" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="0" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <issue_identification>
        <xsl:apply-templates select="volume" mode="copy"/>
        <xsl:apply-templates select="number" mode="copy"/>
        <xsl:apply-templates select="year" mode="copy"/>
        <xsl:apply-templates select="title" mode="copy"/>
      </issue_identification>
      <xsl:apply-templates select="date_published" mode="copy"/>
      <sections>
        <xsl:apply-templates select="section" />
      </sections>
      <articles>
        <xsl:for-each select="section">
          <xsl:apply-templates select="article">
            <xsl:with-param name="date_published" select="preceding-sibling::date_published" />
          </xsl:apply-templates>
        </xsl:for-each>
      </articles>
    </issue>
  </xsl:template>

  <xsl:template match="section">
    <section>
      <xsl:apply-templates select="abbrev" mode="copy"/>
      <xsl:apply-templates select="title" mode="copy"/>
    </section>
  </xsl:template>

  <xsl:template match="articles | papers">
    <articles>
      <xsl:apply-templates />
    </articles>
  </xsl:template>

  <xsl:template match="article | paper">
    <xsl:param name="date_published" />
    <article stage="production" status="3" submission_progress="0" current_publication_id="{format-number(count(preceding::file)+1,'0')}">
      <xsl:if test="string-length($seq)">
        <xsl:attribute name="seq">
          <xsl:value-of select="$seq" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string-length($access_status)">
        <xsl:attribute name="access_status">
          <xsl:value-of select="$access_status" />
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="@*[name()!='language']" />
      <!-- <xsl:if test="not(@language) and string-length(title/@locale)"> -->
      <!--   <xsl:attribute name="language"> -->
      <!--     <xsl:value-of select="substring(title/@locale, 1, 2)" /> -->
      <!--   </xsl:attribute> -->
      <!-- </xsl:if> -->
      <xsl:if test="not(@locale) and string-length(title/@locale)">
        <xsl:attribute name="locale">
          <xsl:value-of select="title/@locale" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="galley"/>
      <xsl:apply-templates select="supplemental_file"/>
      <publication status="3" access_status="0" >
        <xsl:choose>
          <xsl:when test="string-length(date_published)">
            <xsl:attribute name="date_published">
              <xsl:value-of select="date_published" />
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="string-length($date_published)">
            <xsl:attribute name="date_published">
              <xsl:value-of select="$date_published" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="string-length(parent::section/abbrev)">
            <xsl:attribute name="section_ref">
              <xsl:value-of select="parent::section/abbrev" />
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="string-length($section_ref)">
            <xsl:attribute name="section_ref">
              <xsl:value-of select="$section_ref" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <id type="internal" advice="ignore">
          <xsl:value-of select="format-number(count(preceding::file)+1,'0')" />
        </id>
<!--        <id type="doi" advice="update">
          <xsl:value-of select="id[@type='doi']"/>
        </id>-->
        <xsl:apply-templates select="id[@type='doi']"/>
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="abstract"/>
        <xsl:apply-templates select="permissions"/>
        <xsl:apply-templates select="indexing/subject"/>
        <xsl:if test="count(author) !=0">
          <authors>
            <xsl:apply-templates select="author" />
          </authors>
        </xsl:if>
        <xsl:for-each select="galley">
          <article_galley>
            <xsl:apply-templates select="id[@type='doi']"/>
            <name locale="{@locale}">
              <xsl:value-of select="label/text()"/>
            </name>
            <seq>0</seq>
            <submission_file_ref id="{format-number(count(preceding::file)+1,'0')}"/>
          </article_galley>
        </xsl:for-each>
        <xsl:for-each select="supplemental_file">
          <article_galley>
            <xsl:apply-templates select="id[@type='doi']"/>
            <name locale="en_US">
              <xsl:value-of select="'Supplementary'"/>
            </name>
            <seq>0</seq>
            <submission_file_ref id="{format-number(count(preceding::file)+1,'0')}"/>
          </article_galley>
        </xsl:for-each>
      </publication>
      <xsl:if test="not(ancestor::issue) and string-length($volume) and string-length($number) and string-length($year)">
        <issue_identification>
          <volume><xsl:value-of select="$volume" /></volume>
          <number><xsl:value-of select="$number" /></number>
          <year><xsl:value-of select="$year" /></year>
        </issue_identification>
      </xsl:if>
    </article>
  </xsl:template>
  
  <xsl:template match="id[@type='doi']">
    <id type="doi" advice="update">
      <xsl:value-of select="text()"/>
    </id>
  </xsl:template>

  <xsl:template match="title">
    <title>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </title>
  </xsl:template>

  <xsl:template match="abstract">
    <abstract>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </abstract>
  </xsl:template>

  <xsl:template match="author">
    <author id="1" seq="{position()}" user_group_ref="Author">
      <xsl:copy-of select="@*" />
      <xsl:if test="string-length(firstname)">
        <givenname>
          <xsl:if test="string-length(ancestor::article/@locale)">
            <xsl:attribute name="locale">
              <xsl:value-of select="ancestor::article/@locale" />
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="firstname" />
        </givenname>
      </xsl:if>
      <xsl:if test="string-length(lastname)">
        <familyname>
          <xsl:if test="string-length(ancestor::article/@locale)">
            <xsl:attribute name="locale">
              <xsl:value-of select="ancestor::article/@locale" />
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="lastname" />
        </familyname>
      </xsl:if>
      <xsl:apply-templates select="affiliation | country | email" mode="copy"/>
      <xsl:if test="not(string-length(email))">
        <email>email.address@example.com</email>
      </xsl:if>
    </author>
  </xsl:template>

  <xsl:template match="indexing/subject">
    <keywords>
      <xsl:copy-of select="@*" />
      <xsl:call-template name="keywords">
        <xsl:with-param name="subjectString" select="text()" />
      </xsl:call-template>
    </keywords>
  </xsl:template>

  <xsl:template name="keywords">
    <xsl:param name="subjectString" />
    <keyword>
      <xsl:choose>
        <xsl:when test="contains($subjectString, ';')">
          <xsl:value-of select="substring-before($subjectString, ';')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$subjectString" />
        </xsl:otherwise>
      </xsl:choose>
    </keyword>
    <xsl:if test="string-length(substring-after($subjectString, ';')) != 0">
      <xsl:call-template name="keywords">
        <xsl:with-param name="subjectString" select="substring-after($subjectString, ';')" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="license_url">
    <licenseUrl>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </licenseUrl>
  </xsl:template>

  <xsl:template match="copyright_holder">
    <copyrightHolder>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </copyrightHolder>
  </xsl:template>

    <xsl:template match="copyright_year">
    <copyrightYear>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </copyrightYear>
  </xsl:template>

  <xsl:template match="permissions">
      <xsl:apply-templates select="license_url | copyright_holder | *"/>
  </xsl:template>

  <xsl:template match="galley">
    <xsl:apply-templates select="file" >
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="supplemental_file">
      <xsl:apply-templates select="file" >
        <xsl:with-param name="genre" select="@type"/>
      </xsl:apply-templates>
    
  </xsl:template>

  <xsl:template match="file">
    <xsl:param name="genre">Article Text</xsl:param>
    <submission_file stage="proof" id="{format-number(count(preceding::file)+1,'0')}" file_id="{position()}">  
      <xsl:attribute name="genre">
        <xsl:value-of select="concat(translate(substring($genre, 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($genre, 2))"/>
      </xsl:attribute>
<!--      <xsl:apply-templates select="parent::node()/title"/>-->
      <xsl:apply-templates select="parent::node()/creator"/>
      <xsl:apply-templates select="parent::node()/description"/>

      <xsl:variable name="locale" >
        <xsl:if test="ancestor::galley/@locale">
          <xsl:value-of select="ancestor::galley/@locale"/>
        </xsl:if>
        <xsl:if test="not(ancestor::galley/@locale)">en_US</xsl:if>
      </xsl:variable>
      
      <name locale="{$locale}">
        <xsl:value-of select="embed/@filename" />
      </name>

      <xsl:apply-templates select="parent::node()/publisher"/>
      <xsl:apply-templates select="parent::node()/sponsor"/>
      <xsl:apply-templates select="parent::node()/subject"/>
      <file id="{position()}">
        <xsl:apply-templates select="embed | href" />
      </file>
    </submission_file>
  </xsl:template>
  
  <xsl:template match="creator">
    <creator locale="{@locale}">
      <xsl:value-of select="text()"/>
    </creator>
  </xsl:template>
  
  <xsl:template match="description">
    <description locale="{@locale}">
      <xsl:value-of select="text()"/>
    </description>
  </xsl:template>
  
  <xsl:template match="publisher">
    <publisher locale="{@locale}">
      <xsl:value-of select="text()"/>
    </publisher>
  </xsl:template>
  
  <xsl:template match="sponsor">
    <sponsor locale="{@locale}">
      <xsl:value-of select="text()"/>
    </sponsor>
  </xsl:template>
  
  <xsl:template match="subject">
    <subject locale="{@locale}">
      <xsl:value-of select="text()"/>
    </subject>
  </xsl:template>

  <xsl:template match="embed">
    <xsl:attribute name="extension"><xsl:value-of select="substring-after(@filename, '.')" /></xsl:attribute>
    <embed encoding="{@encoding}">
      <xsl:apply-templates select="node()" mode="copy" />
    </embed>
  </xsl:template>

  <xsl:template match="href">
    <xsl:attribute name="extension"><xsl:value-of select="substring-after(@filename, '.')" /></xsl:attribute>
    <xsl:attribute name="filename">
      <xsl:call-template name="parseFilename">
        <xsl:with-param name="fn" select="@src" />
      </xsl:call-template>
    </xsl:attribute>
    <name locale="{ancestor::galley/@locale}">
      <xsl:call-template name="parseFilename">
        <xsl:with-param name="fn" select="@src" />
      </xsl:call-template>
    </name>
    <href src="{@src}" >
      <xsl:apply-templates select="node()" mode="copy" />
    </href>
  </xsl:template>

  <xsl:template match="*" mode="copy">
    <xsl:element name="{name()}" namespace="http://pkp.sfu.ca">
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="node()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="convertBoolean">
    <xsl:attribute name="{name()}" namespace="http://pkp.sfu.ca">
      <xsl:choose>
        <xsl:when test="text() = 'true'">
          <xsl:value-of select="1" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>


  <xsl:template name="parseFilename">
    <xsl:param name="fn" />
    <xsl:choose>
      <xsl:when test="contains($fn, '/')">
        <xsl:call-template name="parseFilename">
          <xsl:with-param name="fn" select="substring-after($fn, '/')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$fn" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
