#!/usr/bin/env bash
# =============================================================================
# Script de création du backlog GitHub pour symfony-tasklist
# Usage : bash create-github-issues.sh
# Prérequis : gh CLI installé et authentifié (gh auth login)
# =============================================================================

set -euo pipefail

REPO="abed31-Cyber/phase3-symfony-tasklist-reloaded"

echo "=== Création des labels ==="

create_label() {
  local name="$1" color="$2" desc="$3"
  gh label create "$name" --color "$color" --description "$desc" --repo "$REPO" 2>/dev/null \
    || echo "  [skip] label '$name' existe déjà"
}

# Type
create_label "feature"       "0075ca" "Nouvelle fonctionnalité"
create_label "bug"           "d73a4a" "Quelque chose ne fonctionne pas"
create_label "security"      "e4e669" "Sécurité et contrôle d'accès"
create_label "config"        "f9d0c4" "Configuration du projet"

# Layer
create_label "backend"       "c2e0c6" "Code PHP / Symfony"
create_label "frontend"      "bfd4f2" "Twig / CSS / JS"
create_label "database"      "d4c5f9" "Doctrine / migrations / fixtures"

# Priorité
create_label "priority-high"   "b60205" "Haute priorité"
create_label "priority-medium" "fbca04" "Priorité moyenne"
create_label "priority-low"    "0e8a16" "Basse priorité"

# Sprint
create_label "sprint-1" "1d76db" "Sprint 1 – Fondations & Sécurité"
create_label "sprint-2" "0052cc" "Sprint 2 – Cœur métier (Tasks)"
create_label "sprint-3" "003d8f" "Sprint 3 – Organisation"
create_label "sprint-4" "002060" "Sprint 4 – Sécurité & Finalisation"

echo ""
echo "=== Création des Milestones ==="

create_milestone() {
  local title="$1" desc="$2"
  gh api repos/"$REPO"/milestones \
    --method POST \
    -f title="$title" \
    -f description="$desc" \
    -f state="open" > /dev/null 2>&1 \
    && echo "  [ok] Milestone '$title' créé" \
    || echo "  [skip] Milestone '$title' existe peut-être déjà"
}

create_milestone "Sprint 1" "Fondations et Sécurité"
create_milestone "Sprint 2" "Cœur métier (Tasks)"
create_milestone "Sprint 3" "Organisation avancée"
create_milestone "Sprint 4" "Sécurité et Finalisation"

# Récupérer les IDs des milestones
MS1=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title=="Sprint 1") | .number')
MS2=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title=="Sprint 2") | .number')
MS3=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title=="Sprint 3") | .number')
MS4=$(gh api repos/"$REPO"/milestones --jq '.[] | select(.title=="Sprint 4") | .number')

echo ""
echo "=== Création des Issues ==="

# -----------------------------------------------------------------------
# ISSUE 1
# -----------------------------------------------------------------------
echo "[1/9] Création Issue #1 : Configuration initiale du projet..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 1] Issue #1 : Configuration initiale du projet" \
  --label "config,backend,priority-high,sprint-1" \
  --milestone "$MS1" \
  --body '**Epic :** Authentification & Base projet
**Labels :** `config`, `backend`, `priority-high`, `sprint-1`
**Estimation :** S (1-2h)
**Dépendances :** aucune
**Milestone :** Sprint 1

#### User Story
En tant que développeur, je veux initialiser le projet Symfony 7 avec une base de données PostgreSQL fonctionnelle afin de pouvoir commencer le développement dans de bonnes conditions.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** un environnement de développement local, **When** je lance `symfony serve`, **Then** le serveur démarre sans erreur et affiche la page d'\''accueil Symfony.
- [ ] **Given** la variable `DATABASE_URL` est correctement renseignée dans `.env.local`, **When** je lance `php bin/console doctrine:database:create`, **Then** la base de données PostgreSQL est créée sans erreur.
- [ ] **Given** la base de données est créée, **When** je lance `php bin/console doctrine:schema:validate`, **Then** le schéma est valide (mapping OK).

#### Checklist technique (sous-tâches)
- [ ] Créer le projet : `symfony new tasklist --version="7.*" --webapp`
- [ ] Installer le driver PostgreSQL : `composer require symfony/orm-pack` + `composer require --dev symfony/maker-bundle`
- [ ] Configurer `.env.local` avec `DATABASE_URL="postgresql://user:pass@127.0.0.1:5432/tasklist?serverVersion=15"`
- [ ] (Optionnel) Ajouter un `docker-compose.yml` avec un service `postgres:15`
- [ ] Lancer `php bin/console doctrine:database:create` pour vérifier la connexion
- [ ] Commiter le projet initial sur la branche `main`

#### Definition of Done
- [ ] Le serveur Symfony démarre sans erreur
- [ ] La connexion à PostgreSQL est fonctionnelle
- [ ] Le projet est versionné sur GitHub
- [ ] Le fichier `.env.local` est dans `.gitignore` (les secrets ne sont pas commités)'

# -----------------------------------------------------------------------
# ISSUE 2
# -----------------------------------------------------------------------
echo "[2/9] Création Issue #2 : Authentification utilisateurs..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 1] Issue #2 : Authentification utilisateurs" \
  --label "feature,backend,security,priority-high,sprint-1" \
  --milestone "$MS1" \
  --body '**Epic :** Authentification & Base projet
**Labels :** `feature`, `backend`, `security`, `priority-high`, `sprint-1`
**Estimation :** L (6-8h+)
**Dépendances :** #1
**Milestone :** Sprint 1

#### User Story
En tant que visiteur, je veux pouvoir créer un compte et me connecter afin d'\''accéder à mon tableau de bord personnel de tâches.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** je suis sur `/register`, **When** je soumets un formulaire valide (email unique + username + mot de passe ≥ 8 caractères), **Then** mon compte est créé, mon mot de passe est hashé en base, et je suis redirigé vers `/dashboard`.
- [ ] **Given** je suis sur `/login`, **When** je soumets mes identifiants corrects, **Then** je suis authentifié et redirigé vers `/dashboard`.
- [ ] **Given** je suis connecté, **When** je clique sur "Se déconnecter", **Then** ma session est détruite et je suis redirigé vers `/login`.
- [ ] **Given** je ne suis pas connecté, **When** j'\''essaie d'\''accéder à `/dashboard`, **Then** je suis redirigé vers `/login`.
- [ ] **Given** je soumets un formulaire d'\''inscription avec un email déjà utilisé, **When** le formulaire est validé, **Then** un message d'\''erreur explicite s'\''affiche.

#### Checklist technique (sous-tâches)
- [ ] Générer l'\''entité User : `php bin/console make:user` (choisir `email` comme identifiant)
- [ ] Ajouter le champ `username` (string, non nullable) à l'\''entité User : `php bin/console make:entity User`
- [ ] Configurer le hash du mot de passe dans `config/packages/security.yaml` (section `password_hashers`)
- [ ] Générer le formulaire d'\''inscription : `php bin/console make:registration-form`
- [ ] Générer le système de login : `php bin/console make:security:form-login`
- [ ] Créer la migration : `php bin/console make:migration && php bin/console doctrine:migrations:migrate`
- [ ] Ajouter la route de logout dans `security.yaml`
- [ ] Configurer `access_control` dans `security.yaml` pour protéger toutes les routes sauf `/login` et `/register`
- [ ] Créer les templates Twig `login.html.twig` et `register.html.twig`
- [ ] Ajouter la redirection post-login vers `/dashboard` dans `security.yaml` (option `default_target_path`)

#### Definition of Done
- [ ] L'\''inscription, la connexion et la déconnexion fonctionnent correctement
- [ ] Les mots de passe sont hashés en base de données (jamais en clair)
- [ ] Les routes protégées redirigent vers `/login` si non authentifié
- [ ] Les messages d'\''erreur de validation sont affichés
- [ ] La migration est jouée et le schéma est à jour
- [ ] Le code est pushé et la PR est mergée'

# -----------------------------------------------------------------------
# ISSUE 3
# -----------------------------------------------------------------------
echo "[3/9] Création Issue #3 : Modélisation des entités Task et Priority..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 2] Issue #3 : Modélisation des entités Task et Priority" \
  --label "feature,backend,database,priority-high,sprint-2" \
  --milestone "$MS2" \
  --body '**Epic :** Gestion des tâches
**Labels :** `feature`, `backend`, `database`, `priority-high`, `sprint-2`
**Estimation :** M (3-5h)
**Dépendances :** #2
**Milestone :** Sprint 2

#### User Story
En tant que développeur, je veux modéliser les entités `Task` et `Priority` avec leurs relations afin de disposer d'\''une base de données structurée pour gérer les tâches utilisateur.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** la migration est jouée, **When** j'\''inspecte la base de données, **Then** les tables `task`, `priority` et `user` existent avec les bons champs et contraintes.
- [ ] **Given** les fixtures sont chargées, **When** je requête la table `priority`, **Then** les 3 priorités par défaut (urgent, important, normal) existent.
- [ ] **Given** une tâche est créée, **When** je consulte son statut, **Then** il vaut bien l'\''une des valeurs de l'\''enum : `pending`, `completed`, `archived`.
- [ ] **Given** deux tâches du même utilisateur, **When** je tente de créer une troisième avec le même `title`, **Then** une contrainte d'\''unicité est levée.

#### Checklist technique (sous-tâches)
- [ ] Créer l'\''enum PHP `Status` dans `src/Enum/Status.php` avec les cases `Pending`, `Completed`, `Archived`
- [ ] Créer l'\''entité Priority : `php bin/console make:entity Priority` → champs : `level` (string, unique), relation `ManyToOne` vers `User`
- [ ] Créer l'\''entité Task : `php bin/console make:entity Task` → champs : `title` (string), `status` (string mappé à l'\''enum), `isPinned` (boolean, default false)
- [ ] Ajouter la relation `Task →(ManyToOne)→ Priority` dans l'\''entité Task
- [ ] Ajouter les relations `User →(OneToMany)→ Task` et `User →(OneToMany)→ Priority` dans l'\''entité User
- [ ] Générer et jouer la migration : `php bin/console make:migration && php bin/console doctrine:migrations:migrate`
- [ ] Installer les fixtures : `composer require --dev doctrine/doctrine-fixtures-bundle`
- [ ] Écrire `src/DataFixtures/AppFixtures.php` (1 utilisateur de test + 3 priorités par défaut)
- [ ] Charger les fixtures : `php bin/console doctrine:fixtures:load`

#### Definition of Done
- [ ] Le schéma est valide (`php bin/console doctrine:schema:validate` passe)
- [ ] Les fixtures se chargent sans erreur
- [ ] Les 3 priorités par défaut sont bien présentes après chargement des fixtures
- [ ] Les relations entre entités sont correctement configurées
- [ ] Le code est pushé et la PR est mergée'

# -----------------------------------------------------------------------
# ISSUE 4
# -----------------------------------------------------------------------
echo "[4/9] Création Issue #4 : Gestion des priorités personnalisées..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 2] Issue #4 : Gestion des priorités personnalisées" \
  --label "feature,backend,frontend,priority-medium,sprint-2" \
  --milestone "$MS2" \
  --body '**Epic :** Gestion des tâches
**Labels :** `feature`, `backend`, `frontend`, `priority-medium`, `sprint-2`
**Estimation :** M (3-5h)
**Dépendances :** #3
**Milestone :** Sprint 2

#### User Story
En tant qu'\''utilisateur connecté, je veux pouvoir créer et supprimer mes propres niveaux de priorité afin de personnaliser l'\''organisation de mes tâches selon mes besoins.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** je suis connecté et sur le dashboard, **When** j'\''ouvre la modale de gestion des priorités, **Then** je vois la liste de mes priorités existantes.
- [ ] **Given** la modale est ouverte, **When** je saisis un nom de priorité et clique sur "+", **Then** la priorité est ajoutée en base et apparaît immédiatement dans la liste.
- [ ] **Given** une priorité existe, **When** je clique sur l'\''icône de suppression, **Then** la priorité est supprimée (si aucune tâche ne lui est assignée) ou un message d'\''erreur s'\''affiche.
- [ ] **Given** je tente de créer une priorité avec un nom déjà existant pour mon compte, **When** le formulaire est soumis, **Then** un message d'\''erreur s'\''affiche.
- [ ] **Given** je suis connecté, **When** je consulte mes priorités, **Then** je ne vois que mes propres priorités.

#### Checklist technique (sous-tâches)
- [ ] Créer le contrôleur : `php bin/console make:controller PriorityController`
- [ ] Créer `src/Service/PriorityService.php` avec les méthodes `create(User, string $level): Priority` et `delete(Priority): void`
- [ ] Créer le formulaire : `php bin/console make:form PriorityType` (champ `level` texte)
- [ ] Ajouter les routes `POST /priority/create` et `DELETE /priority/{id}` dans `PriorityController`
- [ ] Créer le template Twig de la modale `_modal_priority.html.twig`
- [ ] Inclure la modale dans le layout principal via `{% include %}`
- [ ] Ajouter une validation d'\''unicité par utilisateur dans `PriorityService`
- [ ] Gérer la suppression d'\''une priorité assignée à des tâches (afficher un message d'\''erreur clair)

#### Definition of Done
- [ ] L'\''ajout et la suppression de priorités fonctionnent depuis l'\''interface
- [ ] Un utilisateur ne voit et ne modifie que ses propres priorités
- [ ] Les erreurs de validation sont affichées (doublon, priorité utilisée)
- [ ] La logique métier est dans le service, pas dans le contrôleur
- [ ] Le code est pushé et la PR est mergée'

# -----------------------------------------------------------------------
# ISSUE 5
# -----------------------------------------------------------------------
echo "[5/9] Création Issue #5 : Création et affichage des tâches..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 2] Issue #5 : Création et affichage des tâches" \
  --label "feature,backend,frontend,priority-high,sprint-2" \
  --milestone "$MS2" \
  --body '**Epic :** Gestion des tâches
**Labels :** `feature`, `backend`, `frontend`, `priority-high`, `sprint-2`
**Estimation :** L (6-8h+)
**Dépendances :** #3, #4
**Milestone :** Sprint 2

#### User Story
En tant qu'\''utilisateur connecté, je veux pouvoir créer des tâches et les voir s'\''afficher dans mon tableau de bord afin de gérer ma liste de choses à faire.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** je suis sur le dashboard, **When** je clique sur "Nouvelle tâche", **Then** un formulaire s'\''ouvre avec un champ titre et un select de priorité.
- [ ] **Given** je soumets le formulaire avec un titre valide et une priorité, **When** la tâche est créée, **Then** elle apparaît en haut de ma liste avec le badge de priorité correct et le statut "En cours".
- [ ] **Given** j'\''ai des tâches créées, **When** j'\''accède au dashboard, **Then** je vois uniquement mes propres tâches.
- [ ] **Given** le dashboard affiche mes tâches, **When** je les consulte, **Then** chaque tâche montre : titre, badge priorité coloré, statut, et icône épingle.
- [ ] **Given** je tente de créer une tâche avec un titre déjà utilisé, **When** le formulaire est soumis, **Then** un message d'\''erreur s'\''affiche.

#### Checklist technique (sous-tâches)
- [ ] Créer le contrôleur : `php bin/console make:controller TaskController`
- [ ] Créer `src/Repository/TaskRepository.php` avec une méthode `findByUser(User $user): array`
- [ ] Créer le formulaire : `php bin/console make:form TaskType` (champs : `title`, `priority` en `EntityType`)
- [ ] Ajouter la route `GET|POST /task/new` dans `TaskController`
- [ ] Créer la route `GET /dashboard` dans un `DashboardController`
- [ ] Créer le template `dashboard.html.twig` avec la liste des tâches (boucle Twig)
- [ ] Créer le composant Twig `_task_item.html.twig` (titre, badge priorité, statut, épingle)
- [ ] Styliser les badges de priorité (rouge = urgent, orange = important, vert = normal)
- [ ] Ajouter le bouton "Nouvelle tâche" dans le header du dashboard

#### Definition of Done
- [ ] La création de tâche fonctionne et la tâche s'\''affiche immédiatement dans le dashboard
- [ ] Chaque tâche affiche correctement titre, badge priorité, statut et icône épingle
- [ ] Seules les tâches de l'\''utilisateur connecté sont affichées
- [ ] Les erreurs de validation sont affichées
- [ ] Le code est pushé et la PR est mergée'

# -----------------------------------------------------------------------
# ISSUE 6
# -----------------------------------------------------------------------
echo "[6/9] Création Issue #6 : Actions sur les tâches..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 2] Issue #6 : Actions sur les tâches (épinglage, statut, tri)" \
  --label "feature,backend,frontend,priority-high,sprint-2" \
  --milestone "$MS2" \
  --body '**Epic :** Gestion des tâches
**Labels :** `feature`, `backend`, `frontend`, `priority-high`, `sprint-2`
**Estimation :** M (3-5h)
**Dépendances :** #5
**Milestone :** Sprint 2

#### User Story
En tant qu'\''utilisateur connecté, je veux pouvoir épingler, compléter et archiver mes tâches, et les voir triées intelligemment afin de me concentrer sur ce qui est le plus important.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** une tâche est en statut `pending`, **When** je coche la checkbox, **Then** son statut passe à `completed` et son titre s'\''affiche barré.
- [ ] **Given** une tâche est `completed`, **When** je clique sur le bouton d'\''archivage, **Then** son statut passe à `archived` et elle descend en bas de la liste.
- [ ] **Given** une tâche est non épinglée, **When** je clique sur l'\''icône épingle, **Then** `isPinned` passe à `true` et la tâche remonte en haut de la liste.
- [ ] **Given** j'\''ai des tâches de différents statuts et épinglées, **When** j'\''affiche le dashboard, **Then** l'\''ordre est : épinglées > pending > completed > archived.
- [ ] **Given** je suis l'\''utilisateur A, **When** j'\''essaie de modifier une tâche de l'\''utilisateur B, **Then** je reçois une erreur 403.

#### Checklist technique (sous-tâches)
- [ ] Ajouter la route `PATCH /task/{id}/toggle-pin` dans `TaskController` (inverse `isPinned`)
- [ ] Ajouter la route `PATCH /task/{id}/status` dans `TaskController` (cycle `pending` → `completed` → `archived`)
- [ ] Implémenter le tri dans `TaskRepository::findByUser()` via `ORDER BY` : `isPinned DESC`, puis `status`
- [ ] Ajouter la checkbox dans `_task_item.html.twig` (formulaire POST vers `/task/{id}/status`)
- [ ] Ajouter l'\''icône épingle cliquable dans `_task_item.html.twig`
- [ ] Ajouter la classe CSS `line-through` sur le titre quand `task.status == "completed"`
- [ ] Vérifier que l'\''utilisateur connecté est propriétaire de la tâche avant toute modification (`$this->denyAccessUnlessGranted`)

#### Definition of Done
- [ ] L'\''épinglage, le changement de statut et le tri fonctionnent correctement
- [ ] Le titre barré s'\''affiche pour les tâches complétées
- [ ] Un utilisateur ne peut pas modifier les tâches d'\''un autre (403 retourné)
- [ ] L'\''ordre d'\''affichage respecte : épinglées > pending > completed > archived
- [ ] Le code est pushé et la PR est mergée'

# -----------------------------------------------------------------------
# ISSUE 7
# -----------------------------------------------------------------------
echo "[7/9] Création Issue #7 : Gestion des dossiers (Folders)..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 3] Issue #7 : Gestion des dossiers (Folders)" \
  --label "feature,backend,frontend,database,priority-high,sprint-3" \
  --milestone "$MS3" \
  --body '**Epic :** Organisation avancée
**Labels :** `feature`, `backend`, `frontend`, `database`, `priority-high`, `sprint-3`
**Estimation :** L (6-8h+)
**Dépendances :** #5, #6
**Milestone :** Sprint 3

#### User Story
En tant qu'\''utilisateur connecté, je veux pouvoir organiser mes tâches dans des dossiers colorés afin de regrouper mes tâches par projet ou contexte.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** je clique sur "Nouveau dossier" dans la sidebar, **When** je soumets un nom et une couleur valides, **Then** le dossier est créé et apparaît dans la sidebar avec sa pastille couleur.
- [ ] **Given** un dossier est créé, **When** je l'\''affiche dans la sidebar, **Then** je vois le nombre de tâches qu'\''il contient.
- [ ] **Given** je modifie une tâche, **When** j'\''assigne cette tâche à un dossier, **Then** la tâche apparaît dans ce dossier.
- [ ] **Given** je clique sur un dossier dans la sidebar, **When** le filtre s'\''applique, **Then** seules les tâches de ce dossier sont affichées.
- [ ] **Given** je clique sur "Toutes les tâches", **When** la vue se recharge, **Then** toutes mes tâches sont affichées sans filtre de dossier.
- [ ] **Given** deux dossiers du même utilisateur, **When** je tente d'\''en créer un troisième avec le même nom, **Then** un message d'\''erreur s'\''affiche.

#### Checklist technique (sous-tâches)
- [ ] Créer l'\''entité Folder : `php bin/console make:entity Folder` → champs : `name` (string), `color` (string, code hex)
- [ ] Ajouter les relations : `User →(OneToMany)→ Folder` et `Folder →(OneToMany)→ Task` (champ `folder` nullable dans Task)
- [ ] Générer et jouer la migration : `php bin/console make:migration && php bin/console doctrine:migrations:migrate`
- [ ] Créer le contrôleur : `php bin/console make:controller FolderController` (routes `POST /folder/create` et `DELETE /folder/{id}`)
- [ ] Créer le formulaire `FolderType` (champ `name` texte + champ `color` ChoiceType avec 14 couleurs prédéfinies)
- [ ] Créer le template Twig `_modal_folder.html.twig`
- [ ] Modifier la sidebar Twig pour lister les dossiers avec pastille couleur + compteur
- [ ] Ajouter le bouton "Toutes les tâches" en haut de la sidebar
- [ ] Modifier `TaskRepository::findByUser()` pour accepter un paramètre `?Folder $folder = null`
- [ ] Ajouter la sélection de dossier dans `TaskType` (champ `folder` en `EntityType`, nullable)

#### Definition of Done
- [ ] La création, l'\''affichage et la suppression de dossiers fonctionnent
- [ ] Le compteur de tâches par dossier est correct
- [ ] Le filtre par dossier fonctionne depuis la sidebar
- [ ] Un utilisateur ne voit et ne modifie que ses propres dossiers
- [ ] La contrainte d'\''unicité du nom par utilisateur est respectée
- [ ] Le code est pushé et la PR est mergée'

# -----------------------------------------------------------------------
# ISSUE 8
# -----------------------------------------------------------------------
echo "[8/9] Création Issue #8 : Filtres par statut et priorité..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 3] Issue #8 : Filtres par statut et priorité" \
  --label "feature,backend,frontend,priority-medium,sprint-3" \
  --milestone "$MS3" \
  --body '**Epic :** Organisation avancée
**Labels :** `feature`, `backend`, `frontend`, `priority-medium`, `sprint-3`
**Estimation :** M (3-5h)
**Dépendances :** #6, #7
**Milestone :** Sprint 3

#### User Story
En tant qu'\''utilisateur connecté, je veux pouvoir filtrer mes tâches par statut et par priorité afin de trouver rapidement les tâches qui me concernent.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** je suis sur le dashboard, **When** je sélectionne le statut "En cours" dans le dropdown, **Then** seules les tâches avec `status = pending` s'\''affichent.
- [ ] **Given** je suis sur le dashboard, **When** je sélectionne la priorité "Urgent", **Then** seules les tâches avec cette priorité s'\''affichent.
- [ ] **Given** j'\''ai sélectionné un statut ET une priorité, **When** les filtres sont combinés, **Then** seules les tâches correspondant aux deux critères s'\''affichent.
- [ ] **Given** j'\''ai sélectionné un dossier ET un filtre de statut, **When** la page s'\''affiche, **Then** les filtres s'\''appliquent en combinaison.
- [ ] **Given** je réinitialise les filtres (option "Tous"), **When** la page se recharge, **Then** toutes mes tâches sont à nouveau affichées.

#### Checklist technique (sous-tâches)
- [ ] Ajouter les paramètres `?status=` et `?priority=` dans la route `GET /dashboard`
- [ ] Modifier `TaskRepository` pour utiliser un `QueryBuilder` avec des conditions `WHERE` optionnelles
- [ ] Créer la méthode `findByUserFiltered(User $user, ?string $status, ?Priority $priority, ?Folder $folder): array`
- [ ] Ajouter deux `<select>` dans le header du dashboard (statut + priorité)
- [ ] Peupler le select "Priorité" dynamiquement avec les priorités de l'\''utilisateur connecté
- [ ] Utiliser un formulaire `GET` pour que les filtres soient bookmarkables
- [ ] Conserver les filtres actifs dans les `<select>` au rechargement (pré-sélectionner via Twig)
- [ ] S'\''assurer que le filtre dossier est conservé quand on applique un filtre statut/priorité

#### Definition of Done
- [ ] Les filtres par statut et priorité fonctionnent individuellement et en combinaison
- [ ] Les filtres sont compatibles avec le filtre par dossier
- [ ] Les selects restent pré-remplis avec le filtre actif après rechargement
- [ ] Les priorités du select sont celles de l'\''utilisateur connecté uniquement
- [ ] Le code est pushé et la PR est mergée'

# -----------------------------------------------------------------------
# ISSUE 9
# -----------------------------------------------------------------------
echo "[9/9] Création Issue #9 : Sécurité et contrôle d'\''accès..."
gh issue create \
  --repo "$REPO" \
  --title "[SPRINT 4] Issue #9 : Sécurité et contrôle d'accès (Voters)" \
  --label "security,backend,priority-high,sprint-4" \
  --milestone "$MS4" \
  --body '**Epic :** Sécurité & accès
**Labels :** `security`, `backend`, `priority-high`, `sprint-4`
**Estimation :** L (6-8h+)
**Dépendances :** #6, #7, #8
**Milestone :** Sprint 4

#### User Story
En tant qu'\''administrateur du système, je veux m'\''assurer que chaque utilisateur ne peut accéder et modifier que ses propres données (tâches, dossiers, priorités) afin de garantir la confidentialité et l'\''intégrité des données.

#### Critères d'\''acceptation (Given/When/Then)
- [ ] **Given** je suis l'\''utilisateur A connecté, **When** j'\''essaie d'\''accéder à `/task/{id}` appartenant à l'\''utilisateur B, **Then** je reçois une erreur HTTP 403 (Forbidden).
- [ ] **Given** je suis l'\''utilisateur A, **When** j'\''essaie de modifier un dossier appartenant à l'\''utilisateur B, **Then** je reçois une erreur HTTP 403.
- [ ] **Given** je suis l'\''utilisateur A, **When** j'\''essaie de supprimer une priorité appartenant à l'\''utilisateur B, **Then** je reçois une erreur HTTP 403.
- [ ] **Given** je suis non authentifié, **When** j'\''accède à n'\''importe quelle route (sauf `/login` et `/register`), **Then** je suis redirigé vers `/login`.
- [ ] **Given** un Voter est configuré pour Task, **When** `isGranted("TASK_EDIT", $task)` est évalué, **Then** il retourne `true` uniquement si `$task->getUser() === $currentUser`.

#### Checklist technique (sous-tâches)
- [ ] Créer le Voter pour Task : `php bin/console make:voter TaskVoter` → gérer `TASK_VIEW`, `TASK_EDIT`, `TASK_DELETE`
- [ ] Créer le Voter pour Folder : `php bin/console make:voter FolderVoter` → gérer `FOLDER_VIEW`, `FOLDER_EDIT`, `FOLDER_DELETE`
- [ ] Créer le Voter pour Priority : `php bin/console make:voter PriorityVoter` → gérer `PRIORITY_EDIT`, `PRIORITY_DELETE`
- [ ] Dans chaque Voter, vérifier `$subject->getUser() === $token->getUser()` avant d'\''accorder l'\''accès
- [ ] Dans `TaskController`, utiliser `$this->denyAccessUnlessGranted("TASK_EDIT", $task)`
- [ ] Faire de même dans `FolderController` et `PriorityController`
- [ ] Configurer `access_control` dans `config/packages/security.yaml` (ROLE_USER sur tout sauf `/login` et `/register`)
- [ ] Créer la page d'\''erreur 403 : `templates/bundles/TwigBundle/Exception/error403.html.twig`
- [ ] Tester manuellement : créer 2 utilisateurs, tenter d'\''accéder aux ressources de l'\''un avec l'\''autre

#### Definition of Done
- [ ] Les trois Voters sont implémentés et actifs (Task, Folder, Priority)
- [ ] Toutes les routes de modification/suppression utilisent `denyAccessUnlessGranted` avec les Voters
- [ ] L'\''accès aux ressources d'\''un autre utilisateur retourne systématiquement 403
- [ ] Les routes non authentifiées redirigent vers `/login`
- [ ] Le test manuel cross-utilisateur a été effectué et documenté dans la PR
- [ ] Le code est pushé et la PR est mergée'

echo ""
echo "=== ✅ Terminé ! ==="
echo "9 issues, 14 labels et 4 milestones créés dans : https://github.com/$REPO/issues"
