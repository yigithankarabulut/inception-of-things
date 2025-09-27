#!/bin/bash

set -e

# Variables
GITLAB_DOMAIN="gitlab.ykarabul.com"
GITLAB_PORT="8080"
GITHUB_REPO="https://github.com/yigithankarabulut/iot-p3-ykarabul.git"
GITLAB_URL="http://${GITLAB_DOMAIN}:${GITLAB_PORT}"
GITLAB_PROJECT_NAME="iot-p3-ykarabul"
ARGOCD_APP_NAME="argocd-application"
GITLAB_USERNAME="root"

# Get GitLab password
echo "Getting GitLab root password..."
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode)
echo "GitLab Root Password: ${GITLAB_PASSWORD}"

# Get GitLab toolbox pod
GITLAB_TOOLBOX=$(kubectl get pods -n gitlab | grep gitlab-toolbox | awk '{print $1}')
echo "Using GitLab toolbox pod: ${GITLAB_TOOLBOX}"

# Create personal access token via GitLab API
echo "Creating personal access token..."
GITLAB_TOKEN=$(kubectl --namespace gitlab exec -it ${GITLAB_TOOLBOX} -- \
  /srv/gitlab/bin/rails runner " \
    token = User.find_by_username('${GITLAB_USERNAME}').personal_access_tokens.create!( \
      scopes: ['api', 'read_repository', 'write_repository'], \
      name: 'argocd-token', \
      expires_at: 1.year.from_now \
    ); \
    puts token.token \
  " | tr -d '\r\n')
echo "GitLab Generated Token: ${GITLAB_TOKEN}"

# Check if token was generated successfully
if [ -z "${GITLAB_TOKEN}" ] || [ "${GITLAB_TOKEN}" = "null" ]; then
    echo "Error: Failed to generate GitLab token"
    exit 1
fi

# URL encode the token for use in Git remote URL
GITLAB_TOKEN_ENCODED=$(printf '%s' "${GITLAB_TOKEN}" | sed 's/+/%2B/g; s/\//%2F/g; s/=/%3D/g; s/@/%40/g; s/:/%3A/g; s/#/%23/g; s/?/%3F/g; s/&/%26/g')

# Create project in GitLab
echo "Creating project in GitLab..."
curl --request POST \
  --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
  --header "Content-Type: application/json" \
  --data "{\"name\":\"${GITLAB_PROJECT_NAME}\",\"visibility\":\"public\"}" \
  "${GITLAB_URL}/api/v4/projects"

# Clone GitHub repository
echo "Cloning GitHub repository..."
if [ -d "${GITLAB_PROJECT_NAME}" ]; then
    rm -rf "${GITLAB_PROJECT_NAME}"
fi
git clone ${GITHUB_REPO} ${GITLAB_PROJECT_NAME}
cd ${GITLAB_PROJECT_NAME}

# Add GitLab as new origin
echo "Adding GitLab as new origin..."
git remote remove origin || true
git remote add origin "http://${GITLAB_USERNAME}:${GITLAB_TOKEN_ENCODED}@${GITLAB_DOMAIN}:${GITLAB_PORT}/${GITLAB_USERNAME}/${GITLAB_PROJECT_NAME}.git"

# Push to GitLab
echo "Pushing to GitLab..."
if [ -z "$(git log --oneline 2>/dev/null)" ]; then
    echo "Warning: No commits found in repository"
    echo "Creating initial commit..."
    git add . && git commit -m "initial commit"
fi
git push --set-upstream origin --all
git push --set-upstream origin --tags


# Update ArgoCD application
echo "Updating ArgoCD application to use GitLab..."
NEW_REPO_URL="http://gitlab-webservice-default.gitlab.svc:8181/${GITLAB_USERNAME}/${GITLAB_PROJECT_NAME}.git"

# Update the argocd-application.yml file
sed -i "s|repoURL: .*|repoURL: ${NEW_REPO_URL}|g" ../manifests/argocd-application.yml

# Create Gitlab secret for ArgoCD
echo "Creating Gitlab secret for ArgoCD..."
kubectl create secret generic gitlab-repo-secret -n argocd \
    --from-literal=gitlab-token=${GITLAB_TOKEN} \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Repository migration completed!"
echo "GitLab URL: ${GITLAB_URL}"
echo "GitLab Username: ${GITLAB_USERNAME}"
echo "GitLab Password: ${GITLAB_PASSWORD}"
echo "GitLab Token: ${GITLAB_TOKEN}"
echo "New Repository URL: ${NEW_REPO_URL}"
