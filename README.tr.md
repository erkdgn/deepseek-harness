# DeepSeek Harness

[English](README.md) | [中文](README.zh.md) | Türkçe

DeepSeek Harness (`dsh`), açık kaynaklı, genel amaçlı bir kodlama agent'ıdır: bir projedeki dosyaları okur ve düzenler, shell komutları çalıştırır, alt görevleri devreder ve bir plan tutar — tıpkı Claude Code veya benzeri bir agent gibi. Onu ya yerel bir Web UI olarak ya da tek seferlik bir headless komut olarak çalıştırırsın; seçtiğin model provider'ının kendi API key'ini vererek onu o provider'a yönlendirirsin — DeepSeek Harness kendi başına bir key göndermez veya gerektirmez.

**Her şey bir plugin'dir** mimarisini kullanır ve tasarımı [_A Programming Paradigm for Spatiotemporal Composability_](https://github.com/cordiverse/paper) makalesinde anlatılan [Cordis](https://github.com/cordiverse/cordis) tarafından güçlendirilir. Bu repository, `erkdgn/deepseek-harness`, üst akım (upstream) projenin bir fork'udur ve ayrıca `dsh`'yi otomatik pull request incelemesi ve issue triage'ı için de çalıştırır — bkz. aşağıdaki "Bu fork'un eklediği özellikler" bölümü.

## Geliştirici önizlemesi

DeepSeek Harness şu anda _geliştirici önizlemesi_ aşamasındadır ve hızla gelişmektedir. **UYUMLULUĞU BOZAN DEĞİŞİKLİKLER OLACAKTIR.**

## Çalıştırma

### 1. Node.js'i kur

Node.js 22.19+ veya 24+ gerekir (bkz. [package.json](package.json) içindeki `engines`).

### 2. Web UI'yi başlat

```sh
npx @deepseek-ai/dsh web
```

Bu komut `dsh`'yi indirir ve başlatır; varsayılan olarak Web UI'yi `http://127.0.0.1:3080` adresinde yayına sokar. O adresi bir tarayıcıda aç.

### 3. Bir model provider ekle

Web UI'de **Settings → Models**'i aç ve desteklenen bir provider için API key gir — DeepSeek'in kendi API'si olabilir, ya da Anthropic, OpenAI gibi başka bir provider, ya da kendi barındırdığın/OpenAI-uyumlu bir gateway. [Model yapılandırma kılavuzu](docs/user/guide/providers.md), özel provider'lar dahil desteklenen her biçimi kapsar.

### 4. Bir workspace seç ve bir görev çalıştır

**Choose workspace**'e tıkla, `dsh`'nin başlatıldığı proje dizinini ekle, ardından bir session başlat ve ona bir görev gönder — örneğin "Bu repository'yi özetle ve ana paketlerini belirle." Agent, workspace'teki dosyaları okur ve düzenler, komut çalıştırır, ve gerektiğinde etkin izin politikasına göre onay ister. Tam anlatım [Web UI kılavuzunda](docs/user/guide/index.md) yer alır.

## Kaynaktan çalıştırma

Yayınlanmış `npm` paketi yerine bir repository checkout'undan çalıştırmak için — örneğin bu fork'un tam kodunu kullanmak ya da kendi değişikliklerini yapmak istiyorsan:

```sh
git clone https://github.com/erkdgn/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

Tam katkıcı kurulumu ve günlük iş akışı için [geliştirme kılavuzuna](docs/development.md) bak.

## Bu fork'un eklediği özellikler

`dsh`'yi kendi kodlama agent'ın olarak çalıştırmanın ötesinde, bu fork `dsh`'yi otomatik bir ikinci görüş kaynağı olarak da çalıştırır — hem sen çalışırken talep üzerine, hem de bu repository'nin kendi pull request'lerine ve issue'larına karşı CI içinde gözetimsiz olarak.

### Otomatik PR incelemesi ve issue triage'ı

- **`pull_request` olaylarında** (opened, synchronize, reopened), bir job `dsh`'yi kurar, yapılandırılmış bir modele yönlendirir ve doğruluk, güvenlik, concurrency ile eksik hata yönetimini kapsayan bir Markdown inceleme yorumu bırakır — yalnızca tavsiye niteliğindedir, asla engellemez.
- **Yeni açılan issue'larda**, bir job `dsh`'den etiket önermesini ister, ardından yalnızca hem açık bir allowlist'te hem de bu repository'nin gerçek `gh label list` çıktısında görünen etiketleri uygular — böylece ne bir model hatası ne de bir issue gövdesine gizlenmiş bir prompt-injection denemesi keyfi bir etiket uygulayabilir.
- Her hata yolu (eksik key, timeout, provider hatası, boş yanıt) ne olduğunu söyleyen düz bir yorum bırakır ve başarılı şekilde çıkar — bozuk bir otomasyon koşumu asla bir pull request'i engellemez ya da bir issue'yu sessizce triaj edilmemiş bırakmaz.

### Nasıl kurulur

Bu repository'de **Settings → Secrets and variables → Actions** altında:

| Tip | İsim | Değer |
|---|---|---|
| Secret | `DSH_PROVIDER_API_KEY` | Aşağıda yapılandırdığın model provider'ının API key'i — isim provider'a özel değildir, bu yüzden provider değiştirmek asla bir secret yeniden adlandırması gerektirmez. |
| Variable (opsiyonel) | `DSH_PROVIDER_ID` | `llm-pi-ai` route adı. Varsayılan `ollama`. |
| Variable (opsiyonel) | `DSH_PROVIDER_BASE_URL` | Varsayılan `https://ollama.com/v1`. |
| Variable (opsiyonel) | `DSH_PROVIDER_API` | Wire protokolü: `openai-completions` (varsayılan), `openai-responses` ya da `anthropic-messages`. |
| Variable (opsiyonel) | `DSH_MODEL_ID` | Varsayılan `deepseek-v4-pro:0813`. |
| Variable (opsiyonel) | `DSH_ALLOWED_LABELS` | Triage'ın uygulayabileceği etiketler, virgülle ayrılmış. Bunu bu repository'nin gerçek etiketleriyle senkron tut. |
| Variable (opsiyonel) | `MAX_DIFF_LINES`, `MAX_PROMPT_BYTES`, `DSH_REVIEW_TIMEOUT_SECONDS`, `DSH_TRIAGE_TIMEOUT_SECONDS` | Diff boyutu bütçesi, prompt byte bütçesi (shell'in tek argüman sınırının altında) ve job başına timeout süreleri. |

Secret ayarlandıktan sonra, çalıştığını görmek için bu repository'de bir pull request aç (ya da bir tanesine push et) ya da bir issue aç — job'un çıktısı için Actions sekmesine bak.

### dsh'ye kendin danış

Aynı profil, örneğin güvenlik veya concurrency açısından hassas bir değişiklikten önce, elle ve talep üzerine danışma için de kullanılabilir:

```sh
dsh --profile headless "<soru, kod tam olarak yapıştırılmış olarak>"
```

Bunu repository kökünden çalıştır. `dsh` çağrılar arasında hiçbir hafıza tutmaz, bu yüzden "yukarıdaki fonksiyon" gibi bir referans yerine kodu doğrudan prompt'a yapıştır.

### Bu nerede belgeleniyor, ve bilinen sınırları

[`dsh-integration` skill'i](.agents/skills/dsh-integration/SKILL.md) tam referanstır: profilin permission/sandbox/approval yapılandırması, tam prompt kuralları, workflow ve script dosyaları, ve sorun giderme.

Bu otomasyon üç şekilde doğrulandı: stub'lanmış `gh`/`dsh`'ye karşı inceleme ve triage script'lerinin her dalı (aşırı büyük diff, çekme hatası, timeout, provider hatası, boş yanıt, etiket filtreleme); gerçekten yayınlanmış `@deepseek-ai/dsh` paketinin bu tam profili başarıyla kurup birleştirmesi ve gerçek bir (kısıtlı bir sandbox'tan erişilemese de) provider isteği göndermesi; ve secret henüz ayarlanmamışken bu deponun kendi GitHub Actions'ı içindeki gerçek bir tetiklenme — bu tetiklenme gerçek bir açığı ortaya çıkardı (eksik bir secret, bilgilendirici bir yorum bırakmak yerine job'u doğrudan başarısız kılıyordu); bu artık düzeltildi. **Erişilebilir, gerçek bir provider'a karşı bir koşum henüz gözlemlenmedi**; yukarıda açıklanan secret'ı ayarlayarak bunu gözlemleyebilirsin; ilk koşum beklenmedik davranırsa Actions logunu kontrol et.

## Topluluk ve destek

`erkdgn/deepseek-harness`, üst akım (upstream) [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) projesinin bir fork'udur; burada yukarıda açıklanan DSH inceleme ve triage otomasyonunu çalıştırmak için kullanılır. Bu fork'a özgü geri bildirim veya hata raporlarını kendi [GitHub Issues](https://github.com/erkdgn/deepseek-harness/issues) sayfası üzerinden ilet; üst akım ürünün kendi topluluk ve destek kanalları için [kendi README'sine](https://github.com/deepseek-ai/deepseek-harness#readme) bak.

## Katkıda bulunma

Bkz. [CONTRIBUTING.md](CONTRIBUTING.md).

## Geliştirme

[Geliştirme kılavuzu](docs/development.md) ve [mimari dokümantasyonu](docs/architecture.md) ile başla.

Ajanlar için: [AGENTS.md](AGENTS.md)'yi takip et.

## Lisans

[MIT](LICENSE)

Üçüncü taraf bağımlılıklar ve lisansları [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) dosyasında açıklanmıştır.
