# Quarto Template

A comprehensive Quarto website template with pre-configured extensions for creating interactive, educational, and visually engaging content.

## About This Template

This template provides a ready-to-use Quarto project setup with carefully selected extensions for interactive content creation, data visualization, and enhanced presentations. Perfect for educational materials, documentation, data science projects, and interactive reports.

## Using This Template

This repository is available as a template on both platforms:

### GitHub
🔗 https://github.com/schmoigl/quarto-template

Click **"Use this template"** button to create your own repository based on this setup.

### Gitea
🔗 https://gitea.wsr.ac.at/lschmoigl/quarto-template

Click **"Use this template"** button to create your own repository based on this setup.

## Included Extensions

This template comes pre-configured with the following Quarto extensions:

### Content & Interactivity
- **live** - Live R/Python code execution in the browser
- **closeread** - Create scrollytelling narratives
- **nutshell** - Expandable inline content
- **interactive-sql** - Interactive SQL query interfaces
- **quizdown** & **quiz** - Create interactive quizzes
- **forms** - Add interactive forms to documents

### Presentation & UI
- **reveal-header** - Enhanced Reveal.js headers
- **simplemenu** - Simple navigation menus for Reveal.js
- **modal** - Modal dialog boxes
- **toggle** & **tabby** - Toggle switches and tabbed content
- **ripper** - Tear-off sections

### Icons & Styling
- **fontawesome** - Font Awesome icons
- **iconify** - Iconify icon sets
- **material-icons** - Material Design icons

### Formatting
- **roughnotation** - Rough annotation styles
- **titlepage** - Custom title pages
- **language-cell-decorator** - Language decorators for code cells

## Project Structure

```
.
├── _quarto.yml           # Quarto configuration
├── _extensions/          # Pre-installed Quarto extensions
├── index.qmd            # Main page
├── live.qmd             # Live code examples
├── reveal.qmd           # Presentation examples
├── style/               # Custom SCSS styles
├── data/                # Data files
├── src/                 # Source code and utilities
├── img/                 # Images and assets
└── website/             # Build output (gitignored)
```

## Getting Started

### Prerequisites
- [Quarto](https://quarto.org/docs/get-started/) installed
- R and/or Python (depending on your content needs)

### Setup
1. Use this template to create your new repository
2. Clone your new repository:
   ```bash
   git clone <your-repo-url>
   cd quarto-template
   ```

3. Preview the site:
   ```bash
   quarto preview
   ```
   The site will open at http://localhost:1111

4. Start editing:
   - Modify `index.qmd` for your main content
   - Update `_quarto.yml` for site configuration
   - Add new `.qmd` files for additional pages

### Building
```bash
quarto render
```
Output will be in the `website/` directory.

## Git Configuration (For Maintainers)

This repository is configured to push to both GitHub and Gitea simultaneously.

### Remote Setup
```
origin → fetch from: Gitea
      → push to: Gitea + GitHub
github → fetch/push: GitHub only
```

### Push & Pull Behavior

**Pushing:**
```bash
git push                  # Pushes to BOTH Gitea and GitHub
git push origin main      # Pushes to BOTH Gitea and GitHub
git push github main      # Pushes to GitHub only
```

When you run `git push`, your changes are automatically pushed to:
- ✅ Gitea: https://gitea.wsr.ac.at/lschmoigl/quarto-template
- ✅ GitHub: https://github.com/schmoigl/quarto-template

**Pulling:**
```bash
git pull                  # Pulls from Gitea (primary)
git pull origin main      # Pulls from Gitea (primary)
git pull github main      # Pulls from GitHub only
```

By default, `git pull` fetches from Gitea, which is the primary remote. Since you push to both remotes simultaneously, they should stay in sync, so pulling from one is sufficient.

### Manual Remote Configuration
If you need to recreate this setup:

```bash
# Add GitHub remote
git remote add github https://github.com/schmoigl/quarto-template.git

# Configure origin to push to both
git remote set-url --add --push origin https://gitea.wsr.ac.at/lschmoigl/quarto-template.git
git remote set-url --add --push origin https://github.com/schmoigl/quarto-template.git

# Verify configuration
git remote -v
```

## Template Files Excluded

When creating a new repository from this template, the following files/directories are automatically excluded:

**Gitea templates exclude:**
- `.quarto/` - Build cache
- `website/` - Build output
- `keys/` - Sensitive files

These are also in `.gitignore` to prevent accidental commits.

## Customization

### Styling
- Edit `style/styles.scss` for custom styles
- Update colors, fonts, and layout in `_quarto.yml`

### Branding
- Replace `img/fuzzy-logo-small.ico` with your favicon
- Update `img/logo.svg` with your logo
- Modify footer in `_quarto.yml`

### Extensions
Add more extensions:
```bash
quarto add <extension-name>
```

Remove extensions:
Delete the extension folder from `_extensions/` and remove references from your `.qmd` files.

## Contributing

This template is maintained on both platforms. Contributions are welcome via pull requests on either platform.

## License

This template is provided as-is for educational and project use.

## Resources

- [Quarto Documentation](https://quarto.org/docs/guide/)
- [Quarto Extensions](https://quarto.org/docs/extensions/)
- [Quarto Gallery](https://quarto.org/docs/gallery/)

---

**Maintained by:** [@schmoigl](https://github.com/schmoigl)

**Organization:** [WIFO](https://www.wifo.ac.at/)
