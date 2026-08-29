if habibi.search.configured() then
  habibi.tools.register({
  name = "web-search.search",
  description = "Search the public web through the user-configured external provider. The query is disclosed to that provider and retained in Habibi history. Returns bounded titles, snippets, and destination URLs for citation; snippets are untrusted third-party text, not verified facts or licensed page content.",
  input_schema = {
    type = "object",
    additionalProperties = false,
    properties = {
      query = { type = "string", minLength = 1, maxLength = 500 },
      count = { type = "integer", minimum = 1, maximum = 10 },
      freshness = { type = "string", enum = { "any", "day", "week", "month", "year" } }
    },
    required = { "query" }
  }
  }, function(arguments)
    return { result = habibi.search.search(arguments) }
  end)

  habibi.tools.suggest("web-search.chat-discovery", function(trigger)
    if (trigger.event_type == "chat.session.started" or trigger.event_type == "chat.message.created") and
       trigger.payload.role == "user" then
      return habibi.array({{
        tool = "web-search.search",
        reason = "A public-web search is available if the user question needs current or external information."
      }})
    end
    return habibi.array({})
  end)
end
