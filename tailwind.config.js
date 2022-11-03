module.exports = {
  purge: {
    //this is where tailwindcss will look to see what classes were and were not used to purge
    content: ["./app/views/**/*.html.erb", "./app/helpers/**/*rb","./app/javascript/packs/**/*.js"],
  },
  variants: {
    borderWidth: ['responsive', 'first', 'hover', 'focus'],
  },
   theme: {
    typography: {
      default: {
        css: {
          color: '#FFFFF',
          h2: {
            color: '#d03801',
          },
          a: {
            color: '#d03801',
            '&:hover': {
              color: '#ED8936',
            },
          },
          strong: {
            fontWeight: '800',
          },
          // ...
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/ui'),
  ]
}