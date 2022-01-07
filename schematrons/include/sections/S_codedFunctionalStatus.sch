<!--  IHE PCC Coded Functional Status Section: 1.3.6.1.4.1.19376.1.5.3.1.1.12.2.1

S_codedFunctionalStatusAssessment.sch
Vérifie la conformité de la section coded Fucntional Status Assessment en fontion du profil IHE-PCC Supplément

    03/07/2017 : LBE : Création
    30/01/2020 : NMA : Suppression du test sur le nombre de templateId
-->


<pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="S_codedFunctionalStatus">
    <title>IHE PCC Coded Functional Status Section</title>
    
    <rule context='*[cda:templateId/@root="1.3.6.1.4.1.19376.1.5.3.1.1.12.2.1"]'> 
        
        <let name="count_templateId" value="count(cda:templateId)"/>
        
        <assert test="$count_templateId&gt;2">
            [S_codedFunctionalStatusAssessment.sch] Erreur de conformité PCC : L'élément coded Functional Status Assessment doit contenir au moins trois templateIds
        </assert>
        
        <!-- Verifier que le templateId est utilisé pour une section -->
        <assert test='../cda:section'> 
            [S_codedFunctionalStatusAssessment.sch] Erreur de conformité PCC : Ce template ne peut être utilisé que pour une section. 
        </assert>
        
        <!-- Verifier la présence du templateId parent. --> 
        <assert test='cda:templateId[@root="1.3.6.1.4.1.19376.1.5.3.1.3.17"]'> 
            [S_codedFunctionalStatusAssessment.sch] Erreur de conformité PCC : Le templateiD parent est absent. 
        </assert> 
        
        <!-- Vérifier le code de la section --> 
        <assert test='cda:code[@code = "47420-5"]'> 
            [S_codedFunctionalStatusAssessment.sch] Erreur de conformité PCC : Le code de la section 'Progress Note' doit être 47420-5
        </assert> 
        
        <assert test='cda:code[@codeSystem = "2.16.840.1.113883.6.1"]'> 
            [S_codedFunctionalStatusAssessment.sch] Erreur de conformité PCC : L'élément 'codeSystem' de la section 'Progress Note' 
            doit être codé à partir de la nomenclature LOINC 
            (2.16.840.1.113883.6.1). 
        </assert> 
        
        <assert test='cda:id'>
            [S_codedFunctionalStatusAssessment.sch] Erreur de conformité PCC : Les sections doivent avoir un identifiant unique permettant de les identifier.
        </assert>
        
        <assert test="./cda:component/cda:section/cda:templateId[
            @root = '1.3.6.1.4.1.19376.1.5.3.1.1.12.2.3' or
            @root = '1.3.6.1.4.1.19376.1.5.3.1.1.12.2.4' or
            @root = '1.3.6.1.4.1.19376.1.5.3.1.1.12.2.5']">
            [S_codedFunctionalStatusAssessment.sch] Erreur de conformité PCC :  Au moins l'une des sous-sections optionnelles doit être présente. Braden Score Assessment (1.3.6.1.4.1.19376.1.5.3.1.1.12.2.3) ou 
            Geriatric Depression Scale (1.3.6.1.4.1.19376.1.5.3.1.1.12.2.4) ou 
            Minimum Data Set (1.3.6.1.4.1.19376.1.5.3.1.1.12.2.5)
        </assert>
        
        <assert test='.//cda:templateId[@root = "1.3.6.1.4.1.19376.1.5.3.1.1.12.2.2"]'> 
            <!-- Note any missing optional elements -->
            Erreur [codedFunctionalStatusSection]:Cette section Coded Functional Status Assessment ne contient pas de Pain Scale Assessment.
        </assert> 
        

    </rule>
    
</pattern>
        
