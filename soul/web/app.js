const form = document.querySelector("#soul-form");
const prompt = document.querySelector("#prompt");
const count = document.querySelector("#count");
const status = document.querySelector("#status");
const button = form.querySelector("button");
const bytes = value => new TextEncoder().encode(value).length;

function updateCount() {
  count.textContent = `${bytes(prompt.value).toLocaleString()} / 16,384 bytes`;
}

async function request(method = "GET", body) {
  const response = await fetch("./api/soul", {
    method,
    headers: body ? { "content-type": "application/json" } : {},
    body: body ? JSON.stringify(body) : undefined
  });
  const value = await response.json();
  if (!response.ok) throw new Error(value.error || `Request failed (${response.status})`);
  return value;
}

prompt.addEventListener("input", updateCount);
form.addEventListener("submit", async event => {
  event.preventDefault();
  status.className = "";
  status.textContent = "Saving…";
  button.disabled = true;
  try {
    if (bytes(prompt.value) > 16 * 1024) throw new Error("Soul exceeds 16 KiB");
    await request("PUT", { prompt: prompt.value });
    status.textContent = "Soul saved. New model invocations will use it.";
  } catch (error) {
    status.className = "error";
    status.textContent = error.message;
  } finally {
    button.disabled = false;
  }
});

try {
  const value = await request();
  prompt.value = value.prompt || "";
  updateCount();
} catch (error) {
  status.className = "error";
  status.textContent = error.message;
}
