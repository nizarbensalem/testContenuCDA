<?xml version="1.0" encoding="UTF-8"?>

<!-- E_traitementPrescritSubordonnee_fr
     ......................................................................................................................................................
     Vérification de la conformité de l'entrée FR-Traitement-prescrit-subordonnee au spécifications du CI-SIS.
     ......................................................................................................................................................
     Historique :
     - 09/06/2020 : Création
     - 30/11/2020 : Finalisation
-->

    <pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="E_traitementPrescritSubordonnee_fr">
        <title>CI-SIS Entrée "FR-Traitement-prescrit-subordonnee"</title>
        
        <rule context="//cda:entry/cda:substanceAdministration/cda:entryRelationship[@typeCode='COMP']/cda:substanceAdministration[@classCode='SBADM'][@moodCode='INT']">
            <!-- Vérification conformité CI-SIS -->
            <assert test="cda:templateId[@root='1.2.250.1.213.1.1.3.83.1']">
                [1] [E_traitementPrescritSubordonnee_fr.sch] Erreur de conformité CI-SIS : 
                L'entrée "FR-Traitement-prescrit-subordonnee" doit posséder un élément 'templateId' dont l'attribut @root="1.2.250.1.213.1.1.3.83" (Conformité aux spécifications CI-SIS)
            </assert>    
        </rule>   
    </pattern>
