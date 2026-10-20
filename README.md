# dotfiles — Balcón Carmesí

Mi barra de [YASB](https://github.com/amnweb/yasb) para Windows 11, con una paleta sacada del wallpaper: teal de noche, crema, durazno y el rojo de los globos.

![wallpaper](wallpaper/balcon-carmesi.jpg)

## Qué hay

| Archivo | Para qué |
|---|---|
| `config.yaml` | Widgets y layout de YASB |
| `styles.css` | Tema Balcón Carmesí (también trae una variante de día comentada) |
| `wallpaper/balcon-carmesi.jpg` | El wallpaper en el que se basa la paleta |

## La barra

- **Izquierda:** botón `家` (menú de carpetas) y la ventana activa (solo el nombre de la app).
- **Centro:** reloj `Mon 19 · 21:14`; click izquierdo abre el calendario, click derecho muestra la fecha completa.
- **Derecha:**
  - isla de música: controles, título y artista, y un visualizador. Se esconde sola cuando no suena nada.
  - isla del sistema: clima, systray, volumen, notificaciones y centro de control.
- **Alt + Espacio:** buscador de apps. El botón de la lupa está oculto, pero el atajo funciona.

## Instalación

1. Instalá [YASB](https://github.com/amnweb/yasb/releases).
2. Instalá las fuentes:
   - [Zen Kaku Gothic New](https://fonts.google.com/specimen/Zen+Kaku+Gothic+New): el texto de toda la barra (latín y japonés).
   - [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads): los íconos.
3. Copiá `config.yaml` y `styles.css` a `%USERPROFILE%\.config\yasb\`:

   ```powershell
   git clone https://github.com/lvxro/dotfiles "$env:USERPROFILE\.config\yasb"
   ```

4. Poné el wallpaper de `wallpaper/` como fondo de escritorio.
5. En Configuración → Personalización → Barra de tareas, activá **Ocultar automáticamente la barra de tareas**.
6. Reiniciá YASB (`yasbc reload`).

## Ajustes que quizás quieras cambiar

- **Spotifast:** `active_window.ignore_window` excluye `spotifast.exe`, porque lo que suena ya se ve en la isla de música. Si usás Spotify, cambialo por `Spotify.exe`.
- **Tema de día:** en `styles.css`, comentá el bloque "Balcón Carmesí (noche)" y descomentá el de "(día)".
- **Reloj solo con la hora:** en `config.yaml`, cambiá el `label` del `clock` a `'{%H:%M}<span>{alarm}</span>'`.

## Créditos

El wallpaper no es mío; los créditos son del artista original. Si sabés quién es, avisame y lo agrego.
