lemon.defineApp Template.metroHome,
  events:
    "click .app-navigator:not(.locked)": (event, template) -> Router.go $(event.currentTarget).attr('data-app')