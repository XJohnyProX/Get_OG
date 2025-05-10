from fastapi import FastAPI, Query
from playwright.sync_api import sync_playwright
import re

app = FastAPI()

@app.get("/get_og")
def get_og(url: str = Query(...)):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        try:
            page.goto(url, timeout=20000)
            page.wait_for_load_state('domcontentloaded')

            title = page.locator('meta[property="og:title"]').get_attribute('content') or page.title()
            description = page.locator('meta[property="og:description"]').get_attribute('content') or page.locator('meta[name="description"]').get_attribute('content')
            image = page.locator('meta[property="og:image"]').get_attribute('content')

            if not image and ("youtube.com" in url or "youtu.be" in url):
                match = re.search(r'(?:v=|\/)([a-zA-Z0-9_-]{11})', url)
                if match:
                    video_id = match.group(1)
                    image = f"https://i.ytimg.com/vi/{video_id}/hqdefault.jpg"

            return {
                "title": title,
                "description": description,
                "image": image
            }
        except Exception as e:
            return {"error": str(e)}
        finally:
            browser.close()
