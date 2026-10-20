# SICP

Esta es una traducción no oficial de [Structure and Interpretation of Computer Programs](https://web.mit.edu/6.001/6.037/sicp.pdf), actualmente en progreso. Usamos [Typst](https://typst.app) para el proyecto.

## ¿Cómo contribuir?

Para trabajar en el libro se requiere tener [Typst](https://typst.app) instalado. Este repositorio provee un entorno de [Nix](https://nixos.org/download/) para obtener todas las dependencias necesarias y garantizar que el archivo resultante es siempre el mismo. Se puede trabajar en el proyecto *con* Nix o *sin* Nix.

### Sin Nix

- Instala Typst ([página de descargas](https://typst.app/open-source/#download)).

- En el directorio del proyecto, usa el comando `typst compile main.typ` para producir un PDF con el libro. Puedes usar `typst watch main.typ` para que el archivo se actualice automáticamente cuando haces cambios, muy útil cuando estás editando.

### Con Nix

- Instala Nix ([página de descargas](https://nixos.org/download/))

- Asegurate de [activar los Flakes](https://nixos.wiki/wiki/Flakes).

- En el directorio del proyecto, usa el comando `nix run .#build` para producir un PDF con el libro. Usa `nix run` para que el libro se actualice automáticamente con los cambios.

- Si deseas tener una consola donde puedas usar Typst libremente, usa `nix develop`.
