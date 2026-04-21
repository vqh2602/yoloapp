#!/usr/bin/env python3
"""
Scaffold a package_name GetX module and wire it into lib/routes/routes.dart.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


def snake_case(value: str) -> str:
    normalized = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", value.strip())
    normalized = re.sub(r"[^A-Za-z0-9]+", "_", normalized)
    normalized = normalized.strip("_").lower()
    normalized = re.sub(r"_+", "_", normalized)
    return normalized


def pascal_case(value: str) -> str:
    return "".join(part.capitalize() for part in snake_case(value).split("_") if part)


def kebab_case(value: str) -> str:
    return snake_case(value).replace("_", "-")


def read_package_name(pubspec_path: Path) -> str:
    for line in pubspec_path.read_text().splitlines():
        if line.startswith("name:"):
            return line.split(":", 1)[1].strip().strip("'\"")
    raise ValueError(f"Cannot find package name in {pubspec_path}")


def ensure_project_root(project_root: Path) -> tuple[Path, Path, str]:
    pubspec_path = project_root / "pubspec.yaml"
    routes_path = project_root / "lib/routes/routes.dart"
    if not pubspec_path.exists():
        raise FileNotFoundError(f"Missing pubspec.yaml in {project_root}")
    if not routes_path.exists():
        raise FileNotFoundError(f"Missing lib/routes/routes.dart in {project_root}")
    package_name = read_package_name(pubspec_path)
    return pubspec_path, routes_path, package_name


def responsive_screen_template(
    package_name: str,
    module_name: str,
    screen_class: str,
    mobile_screen_class: str,
    route_segment: str,
) -> str:
    return f"""import 'package:flutter/material.dart';
import 'package:{package_name}/app/modules/{module_name}/{module_name}_screen_mobile.dart';
import 'package:{package_name}/configurations/configurations.dart';
import 'package:serp_core_modules/widgets/serp/responsive/responsive_layout.dart';

class {screen_class} extends StatefulWidget {{
  static String routeName =
      '${{Env.config.APP_CONFIG.PREFIX_MODULE}}/{route_segment}';

  const {screen_class}({{super.key}});

  @override
  State<{screen_class}> createState() => _{screen_class}State();
}}

class _{screen_class}State extends State<{screen_class}> {{
  @override
  Widget build(BuildContext context) {{
    return const ResponsiveLayout(
      mobileResponsive: {mobile_screen_class}(),
      tabletResponsive: {mobile_screen_class}(),
      desktopResponsive: {mobile_screen_class}(),
    );
  }}
}}
"""


def sbase_screen_template(
    package_name: str,
    module_name: str,
    mobile_screen_class: str,
    screen_class: str,
    route_segment: str,
) -> str:
    return f"""import 'package:flutter/material.dart';
import 'package:{package_name}/app/modules/{module_name}/{module_name}_screen_mobile.dart';
import 'package:serp_core_modules/s_core_module.dart';

class {screen_class} extends SBaseScreen {{
  static const String routeName = '/{route_segment}';

  const {screen_class}({{super.key}});

  @override
  State<{screen_class}> createState() => _{screen_class}State();
}}

class _{screen_class}State extends BaseState<{screen_class}> {{
  @override
  Widget build(BuildContext context) {{
    return const {mobile_screen_class}();
  }}
}}
"""


def mobile_screen_template(
    package_name: str,
    module_name: str,
    controller_class: str,
    mobile_screen_class: str,
    module_title: str,
) -> str:
    return f"""import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:{package_name}/app/modules/{module_name}/{module_name}_controller.dart';
import 'package:serp_core_modules/s_core_module.dart';

class {mobile_screen_class} extends SBaseScreen {{
  const {mobile_screen_class}({{super.key}});

  @override
  State<{mobile_screen_class}> createState() => _{mobile_screen_class}State();
}}

class _{mobile_screen_class}State extends BaseState<{mobile_screen_class}>
    with BasicStateMixin {{
  final {controller_class} controller = Get.find<{controller_class}>();

  @override
  bool isSafeAreaTop = true;

  @override
  Widget createBody() {{
    return controller.obxS(
      (state) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '{module_title} screen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      onLoading: const Center(child: CircularProgressIndicator()),
      onError: (error) => Center(
        child: Text(error ?? 'Something went wrong'),
      ),
      onEmpty: const Center(child: Text('No data')),
    );
  }}
}}
"""


def controller_template(controller_class: str) -> str:
    return f"""import 'package:get/get.dart';

class {controller_class} extends GetxController with StateMixin {{
  @override
  Future<void> onInit() async {{
    await loadInitialData();
    super.onInit();
  }}

  Future<void> loadInitialData() async {{
    change(null, status: RxStatus.loading());
    await Future<void>.delayed(Duration.zero);
    change(null, status: RxStatus.success());
  }}

  Future<void> refreshData() async {{
    await loadInitialData();
  }}
}}
"""


def binding_template(
    package_name: str,
    module_name: str,
    binding_class: str,
    controller_class: str,
) -> str:
    return f"""import 'package:get/get.dart';
import 'package:{package_name}/app/modules/{module_name}/{module_name}_controller.dart';

class {binding_class} extends Bindings {{
  @override
  void dependencies() {{
    Get.lazyPut<{controller_class}>(
      () => {controller_class}(),
      fenix: true,
    );
  }}
}}
"""


def write_file(path: Path, content: str) -> None:
    path.write_text(content)
    print(f"[OK] Created {path}")


def insert_imports(routes_content: str, imports_to_add: list[str]) -> str:
    insert_at = routes_content.find("List<GetPage> routes = [")
    if insert_at == -1:
        raise ValueError("Cannot find routes list in lib/routes/routes.dart")

    existing = set(re.findall(r"^import '.*';$", routes_content, re.MULTILINE))
    missing = [line for line in imports_to_add if line not in existing]
    if not missing:
        return routes_content

    prefix = routes_content[:insert_at].rstrip()
    suffix = routes_content[insert_at:]
    return prefix + "\n" + "\n".join(missing) + "\n\n" + suffix


def insert_route(routes_content: str, route_entry: str, route_name_marker: str) -> str:
    if route_name_marker in routes_content:
        return routes_content

    closing = routes_content.rfind("];")
    if closing == -1:
        raise ValueError("Cannot find the end of routes list in lib/routes/routes.dart")

    prefix = routes_content[:closing].rstrip()
    suffix = routes_content[closing:]
    return prefix + "\n" + route_entry + "\n" + suffix


def update_routes(
    routes_path: Path,
    package_name: str,
    module_name: str,
    screen_class: str,
    binding_class: str,
) -> None:
    routes_content = routes_path.read_text()
    import_lines = [
        f"import 'package:{package_name}/app/modules/{module_name}/{module_name}_binding.dart';",
        f"import 'package:{package_name}/app/modules/{module_name}/{module_name}_screen.dart';",
    ]
    routes_content = insert_imports(routes_content, import_lines)

    route_entry = f"""  GetPage(
    name: {screen_class}.routeName,
    page: () => const {screen_class}(),
    binding: {binding_class}(),
  ),"""
    routes_content = insert_route(
        routes_content,
        route_entry,
        f"name: {screen_class}.routeName,",
    )
    routes_path.write_text(routes_content)
    print(f"[OK] Updated {routes_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scaffold a Marineradar GetX module and add it to routes.dart.",
    )
    parser.add_argument("--project-root", required=True, help="Path to the Marineradar repo")
    parser.add_argument("--module", required=True, help="Module folder name")
    parser.add_argument(
        "--route-segment",
        help="Route segment used in routeName. Defaults to the module name in kebab-case.",
    )
    parser.add_argument(
        "--screen-style",
        choices=("responsive", "sbase"),
        default="responsive",
        help="Base screen style to generate.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    _, routes_path, package_name = ensure_project_root(project_root)

    module_name = snake_case(args.module)
    if not module_name:
        raise ValueError("Module name cannot be empty")

    route_segment = args.route_segment.strip() if args.route_segment else kebab_case(module_name)
    module_dir = project_root / "lib/app/modules" / module_name
    if module_dir.exists():
        raise FileExistsError(f"Module already exists: {module_dir}")

    module_dir.mkdir(parents=True)
    (module_dir / "widgets").mkdir()

    module_title = pascal_case(module_name)
    screen_class = f"{module_title}Screen"
    mobile_screen_class = f"{module_title}ScreenMobile"
    controller_class = f"{module_title}Controller"
    binding_class = f"{module_title}Binding"

    if args.screen_style == "responsive":
        screen_content = responsive_screen_template(
            package_name=package_name,
            module_name=module_name,
            screen_class=screen_class,
            mobile_screen_class=mobile_screen_class,
            route_segment=route_segment,
        )
    else:
        screen_content = sbase_screen_template(
            package_name=package_name,
            module_name=module_name,
            mobile_screen_class=mobile_screen_class,
            screen_class=screen_class,
            route_segment=route_segment,
        )

    write_file(module_dir / f"{module_name}_screen.dart", screen_content)
    write_file(
        module_dir / f"{module_name}_screen_mobile.dart",
        mobile_screen_template(
            package_name=package_name,
            module_name=module_name,
            controller_class=controller_class,
            mobile_screen_class=mobile_screen_class,
            module_title=module_title,
        ),
    )
    write_file(module_dir / f"{module_name}_controller.dart", controller_template(controller_class))
    write_file(
        module_dir / f"{module_name}_binding.dart",
        binding_template(
            package_name=package_name,
            module_name=module_name,
            binding_class=binding_class,
            controller_class=controller_class,
        ),
    )

    update_routes(
        routes_path=routes_path,
        package_name=package_name,
        module_name=module_name,
        screen_class=screen_class,
        binding_class=binding_class,
    )

    print(f"[OK] Scaffolded module '{module_name}' in {module_dir}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        print(f"[ERROR] {error}", file=sys.stderr)
        sys.exit(1)
