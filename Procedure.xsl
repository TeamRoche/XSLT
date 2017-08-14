<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Procedure">
		<xsl:if test="@moodCode ='INT'">
		<Procedure>
				<Extension>
					<ProcedureRequest>
						<EncounterNumber>
							<xsl:apply-templates select="." mode="EncounterID-Entry"/>
						</EncounterNumber>
						<xsl:apply-templates select="." mode="PlacerId"/>

						<xsl:apply-templates select="." mode="FillerId"/>
						<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
						<xsl:apply-templates select="hl7:code" mode="CodeTable">
							<xsl:with-param name="hsElementName" select="'OrderItem'"/>
							<xsl:with-param name="importOriginalText" select="'1'"/>
						</xsl:apply-templates>
						<!--<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:author" mode="OrderedBy-Author"/>-->
					</ProcedureRequest>
					<Status>
						<xsl:choose>
							<xsl:when test="hl7:statusCode/@code = 'completed'">F</xsl:when>
							<xsl:otherwise>U</xsl:otherwise>
						</xsl:choose>
					</Status>
					<ProcedureTime>
						<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/@value)"/>
					</ProcedureTime>
				</Extension>
			</Procedure>
		</xsl:if>

		<xsl:if test="not(@moodCode ='INT')">
			<Procedure>

				<!--
				Field : Procedure Encounter
				Target: HS.SDA3.Procedure EncounterNumber
				Target: /Container/Procedures/Procedure/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Procedure and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->




				<EncounterNumber>
					<xsl:apply-templates select="." mode="EncounterID-Entry"/>
				</EncounterNumber>

				<!--
				Field : Procedure Author
				Target: HS.SDA3.Procedure EnteredBy
				Target: /Container/Procedures/Procedure/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/author
				StructuredMappingRef: EnteredByDetail
			-->
				<xsl:apply-templates select="." mode="EnteredBy"/>
				<!--
				Field : Procedure Information Source
				Target: HS.SDA3.Procedure EnteredAt
				Target: /Container/Procedures/Procedure/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/informant
				StructuredMappingRef: EnteredAt
			-->
				<xsl:apply-templates select="." mode="EnteredAt"/>

				<!--
				Field : Procedure Author Time
				Target: HS.SDA3.Procedure EnteredOn
				Target: /Container/Procedures/Procedure/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/author/time/@value
			-->
				<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>

				<!--
				Field : Procedure Id
				Target: HS.SDA3.Procedure ExternalId
				Target: /Container/Procedures/Procedure/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/id
				StructuredMappingRef: ExternalId
			-->
				<xsl:apply-templates select="." mode="ExternalId"/>

				<!--
				Field : Procedure Type
				Target: HS.SDA3.Procedure Procedure
				Target: /Container/Procedures/Procedure/Procedure
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/code
				StructuredMappingRef: CodeTableDetail
			-->
				<xsl:apply-templates select="hl7:code" mode="CodeTable">
					<xsl:with-param name="hsElementName" select="'Procedure'"/>
					<xsl:with-param name="importOriginalText" select="'1'"/>
				</xsl:apply-templates>

				<!--
				Field : Procedure Date/Time
				Target: HS.SDA3.Procedure ProcedureTime
				Target: /Container/Procedures/Procedure/ProcedureTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/effectiveTime/@value
				Note  : Procedure CDA effectiveTime should have only a single
						value, but it is legal to have a high and a low value.
						When importing to SDA ProcedureTime, use the first found
						of effectiveTime/@value, effectiveTime/low/@value,
						effectiveTime/high/@value.
			-->
				<xsl:choose>
					<xsl:when test="hl7:effectiveTime/@value">
						<xsl:apply-templates select="hl7:effectiveTime" mode="ProcedureTime"/>
					</xsl:when>
					<xsl:when test="hl7:effectiveTime/hl7:low/@value">
						<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="ProcedureTime"/>
					</xsl:when>
					<xsl:when test="hl7:effectiveTime/hl7:high/@value">
						<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ProcedureTime"/>
					</xsl:when>
				</xsl:choose>

				<!--
				Field : Procedure Provider
				Target: HS.SDA3.Procedure Clinician
				Target: /Container/Procedures/Procedure/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/performer
				StructuredMappingRef: Clinician
			-->
				<xsl:apply-templates select="hl7:performer" mode="Clinician"/>

				<!-- Custom SDA Data-->
				<xsl:apply-templates select="." mode="ImportCustom-Procedure"/>

				<Extension>
					<Status>
						<xsl:choose>
							<xsl:when test="hl7:statusCode/@code = 'completed'">F</xsl:when>
							<xsl:otherwise>U</xsl:otherwise>
						</xsl:choose>
					</Status>
				</Extension>
			
			</Procedure>
		</xsl:if>

	</xsl:template>


	<xsl:template match="*" mode="ProcedureTime">
		<Extension>
			<ProcedureTime>
				<xsl:choose>
					<xsl:when test="hl7:effectiveTime/@value">
						<xsl:apply-templates select="hl7:effectiveTime" mode="ProcedureTime"/>
					</xsl:when>
					<xsl:when test="hl7:effectiveTime/hl7:low/@value">
						<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="ProcedureTime"/>
					</xsl:when>
					<xsl:when test="hl7:effectiveTime/hl7:high/@value">
						<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ProcedureTime"/>
					</xsl:when>
				</xsl:choose>
			</ProcedureTime>
		</Extension>
	</xsl:template>



	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:procedure.
	-->
	<xsl:template match="*" mode="ImportCustom-Procedure">
	</xsl:template>
</xsl:stylesheet>
