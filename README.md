# Personal Blog (Astro)

This project is an Astro blog starter configured for GitHub Pages deployment.

## Local development

```bash
npm install
npm run dev
```

## Build locally

```bash
npm run build
npm run preview
```

## Deploy to GitHub Pages

1. Push this project to a GitHub repository.
2. In GitHub, open `Settings -> Pages`.
3. Set `Source` to `GitHub Actions`.
4. Push to the `main` branch.
5. Wait for the `Deploy to GitHub Pages` workflow to finish.

The workflow automatically sets:
- `SITE`: `https://<owner>.github.io`
- `BASE_PATH`: `/` for `<owner>.github.io` repo, otherwise `/<repo-name>`

So this works for both:
- user/org site repos (`<owner>.github.io`)
- project site repos (`any-other-repo`)
