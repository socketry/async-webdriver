# Navigation Timing

This guide explains how to avoid race conditions when triggering navigation operations while browser navigation is already in progress.

## The Problem

When you trigger navigation in a browser (form submission, link clicks), the browser starts a complex process that takes time. If you call `navigate_to` while this process is still running, it will interrupt the ongoing navigation, potentially causing:

- Server-side effects (like setting session cookies) to not complete.
- The intended navigation to never finish.
- Your test to end up in an unexpected state.

## Understanding the Race Condition

When you trigger navigation (form submission, link clicks), the browser starts a process:

1. **Submit Request**: Form data is sent to the server.
2. **Server Processing**: Server handles the request (authentication, validation, etc.).
3. **Response**: Server sends back response (redirect, new page, etc.).
4. **Browser Navigation**: Browser processes the response and updates the page.
5. **Page Load**: New page loads and `document.readyState` becomes "complete".

If any navigation operation is triggered during steps 1-4, it **interrupts** this process:
- Server-side effects (like setting session cookies) may not complete.
- The intended navigation never finishes.
- Your test ends up in an unexpected state.

## Problematic Code Examples

### Example 1: Login Form Race Condition

```ruby
# ❌ PROBLEMATIC: May interrupt login before authentication completes
session.click_button("Login")        # Triggers form submission
session.navigate_to("/dashboard")    # May interrupt login process!
```

### Example 2: Form Submission Race Condition

```ruby
# ❌ PROBLEMATIC: May interrupt form submission
session.fill_in("email", "user@example.com")
session.click_button("Subscribe")    # Triggers form submission
session.navigate_to("/thank-you")    # May interrupt subscription action on server!
```

## Detection and Mitigation Strategies

⚠️ **Important**: Element-based waits (`find_element`) are **insufficient** for preventing race conditions because navigation can be interrupted before target elements ever appear on the page.

### Reliable Strategy: Use `wait_for_navigation`

The most reliable approach is to use `wait_for_navigation` to wait for the URL or page state to change:

```ruby
# ✅ RELIABLE: Wait for URL change
session.click_button("Submit")
session.wait_for_navigation {|url| url.end_with?("/success")}
session.navigate_to("/next-page") # Now safe
```

### Alternative: Wait for Server-Side Effects

For critical operations like authentication, wait for server-side effects to complete:

```ruby
# ✅ RELIABLE: Wait for authentication cookie
session.click_button("Login")
session.wait_for_navigation do |url, ready_state|
  ready_state == "complete" && 
  session.cookies.any? {|cookie| cookie['name'] == 'auth_token'}
end
session.navigate_to("/dashboard") # Now safe
```

### Unreliable Approaches (Common But Insufficient)

These approaches are commonly used but **may still allow race conditions**:

#### Element-based Waits

Unfortunately, waiting for specific elements to appear does not always work when navigation operations are in progress. In some cases, the element isn't present before the navigation starts, which can cause hangs. However, sometimes it may work by chance, if the navigation completes before the find element call is invoked. It also appears to depend on which browser is being used, and perhaps even which version of that browser.

```ruby
# ❌ UNRELIABLE: Navigation can be interrupted before element appears
session.click_button("Submit")

# In principle, wait for the form submission to complete:
session.find_element(xpath: "//h1[text()='Success']")
# However, in reality it may:
# 1. Fail to find element on initial page, or
# 2. Hang if the navigation is still in progress.
# 3. Succeed by chance if navigation has completed sufficiently.

# Assuming the previous operation did not hang, this navigation may interrupt the form submission:
session.navigate_to("/next-page")
```

#### Generic Page Waits

```ruby
# ❌ UNRELIABLE: Doesn't ensure the intended navigation completed
session.click_button("Submit")

# This can find the wrong element on the initial page before the form submission causes a page navigation operation:
session.find_element(xpath: "//html")

# This navigation may interrupt the form submission:
session.navigate_to("/next-page")
```

These approaches fail because `navigate_to` can interrupt the ongoing navigation before the target page (and its elements) ever loads.

## Best Practices Summary

1. **Always wait** after triggering navigation before calling `navigate_to` again.
2. **Use `wait_for_navigation`** with URL or state conditions for reliable synchronization.
3. **Test for race conditions** in your test suite with deliberate delays.
4. **Avoid element-based waits** for navigation synchronization (they're unreliable).
5. **Consider server-side effects** when designing wait conditions.
6. **Prefer URL-based waits** over element-based waits for navigation timing.

## Common Pitfalls

- **Don't assume** `click_button` waits for navigation to complete.
- **Don't rely on** element-based waits (`find_element`) to prevent race conditions.
- **Don't use** arbitrary `sleep` calls instead of proper synchronization.
- **Don't ignore** server-side effects like cookie setting or session management.
- **Don't chain** multiple navigation operations without URL-based synchronization.
