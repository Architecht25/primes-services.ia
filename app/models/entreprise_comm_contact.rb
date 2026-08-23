# Sous-type STI conservé uniquement pour la compatibilité avec les demandes historiques
# (colonne `type` = "EntrepriseCommContact" en base). Le formulaire de contact est désormais
# unique et générique : toute nouvelle demande est créée directement en ContactSubmission.
class EntrepriseCommContact < ContactSubmission
end
